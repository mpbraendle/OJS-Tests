import pytest
from playwright.sync_api import Page, expect
import re

from testing_playwright.conftest import ojs_version


@pytest.fixture
def login(page: Page, base_url: str, ojs_version: str):
    def _login(ojs_user: str, ojs_pass: str, ):
        match ojs_version:
            case "3.3":
                page.goto(f"{base_url}/login")
                expect(page).to_have_url(f"{base_url}/login")
                page.fill('input[name="username"]', ojs_user)
                page.fill('input[name="password"]', ojs_pass)
                page.click('button[type="submit"]')
                expect(page).to_have_url(f"{base_url}/submissions")
            case "3.5":
                page.goto(f"{base_url}/login")
                #expect(page).to_have_url(f"{base_url}/login")
                page.fill('input[name="username"]', ojs_user)
                page.fill('input[name="password"]', ojs_pass)
                page.click('button[type="submit"]')
                #expect(page).to_have_url(f"{base_url}/submissions")
            case _:
                raise ValueError(f"Unsupported OJS version: {ojs_version}")

    return _login


@pytest.fixture(autouse=True)
def authenticate(login, request):
    user = request.config.getoption("--ojs-user")
    pw = request.config.getoption("--ojs-pass")
    login(user, pw)


class TestBackend:
    def test_standard_login(self, page: Page, base_url: str, ojs_version: str):
        match ojs_version:
            case '3.3':
                expect(page).to_have_url(f"{base_url}/submissions")
            case '3.5':
                expect(page).to_have_url(
                    re.compile(
                        # Validates against Base URL + Language Code + /dashboard/editorial + Get-Parameters
                        rf"^https?://{re.escape(base_url.removeprefix('http://').removeprefix('https://'))}/[a-zA-Z]{{2}}/dashboard/editorial(?:\?.*)?$"
                    )
                )
            case _:
                raise ValueError(f"Unsupported OJS version: {ojs_version}")

    def test_plugin_gallery(self, page: Page, base_url: str):
        response = page.goto(f"{base_url}/management/settings/website#plugins/pluginGallery")
        assert response.status == 200
        page.wait_for_load_state('networkidle')
        expect(page.locator('#component-grid-plugins-plugingallerygrid-row-0')).to_be_visible()

    def test_issue_list(self, page: Page, base_url: str):
        response = page.goto(f"{base_url}/manageIssues#future")
        assert response.status == 200
        expect(page.locator('div[id^="component-grid-issues-futureissuegrid-"]')).to_be_visible()

    def test_plugin_list(self, page: Page, base_url: str):
        response = page.goto(f"{base_url}/management/settings/website#plugins")
        assert response.status == 200
        expect(
            page.locator('[id^="component-grid-settings-plugins-settingsplugingrid-category-"]').first).to_be_visible()

    def test_plugin_existence(self, page: Page, base_url: str, existing_plugin: str):
        response = page.goto(f"{base_url}/management/settings/website#plugins")
        assert response.status == 200, 'Page returned status code other than 200'
        expect(page.get_by_text(existing_plugin).last).to_be_visible(timeout=3000)

    def test_statistics(self, page: Page, base_url: str, ojs_version: str):
        response = page.goto(f"{base_url}/stats/publications/publications")
        assert response.status == 200
        match ojs_version:
            case '3.3':
                expect(page.locator('tr.pkpTable__row').first).to_be_visible()
            case '3.5':
                expect(page.locator('.pkpStats__panel>div>table').first).to_be_visible()
            case _:
                raise ValueError(f"Unsupported OJS version: {ojs_version}")

    def test_submissions_active(self, page: Page, base_url: str, ojs_version: str):
        response = page.goto(f"{base_url}/submissions")
        assert response.status == 200
        match ojs_version:
            case '3.3':
                page.click('#active-button')
                page.wait_for_load_state('networkidle')
            case '3.5':
                ...
            case _:
                raise ValueError(f"Unsupported OJS version: {ojs_version}")
        expect(page.get_by_role("link", name="New Submission").first).to_be_visible()

    def test_user_list(self, page: Page, base_url: str, ojs_version: str):
        response = page.goto(f"{base_url}/management/settings/access")
        assert response.status == 200
        match ojs_version:
            case '3.3':
                expect(page.locator('[id^="component-grid-settings-user-usergrid-"]').first).to_be_visible()
            case '3.5':
                expect(page.locator('#users').first).to_be_visible()
            case _:
                raise ValueError(f"Unsupported OJS version: {ojs_version}")


    def test_admin_page(self, page: Page, base_url: str):
        response = page.goto(f"{base_url}/../index/admin")
        page.wait_for_load_state('networkidle')
        assert response.status == 200
