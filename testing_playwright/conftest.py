import os
import pytest
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

@pytest.fixture(scope="session")
def base_url(request):
    return request.config.getoption("--ojs-base-url")


@pytest.fixture(scope="session")
def ojs_user(request):
    base_url = request.config.getoption("--ojs-user")
    return base_url

@pytest.fixture(scope="session")
def ojs_pass(request):
    return request.config.getoption("--ojs-pass")

@pytest.fixture(scope="session")
def theme(request):
    return request.config.getoption("--theme")

@pytest.fixture(scope="session")
def existing_plugin(request):
    return request.config.getoption("--existing_plugin")

@pytest.fixture(scope="session")
def ojs_version(request):
    return request.config.getoption("--ojs-version")

@pytest.fixture(scope="session")
def ojs_language(request):
    return request.config.getoption("--ojs-language")


def pytest_addoption(parser):
    parser.addoption("--ojs-base-url", action="store", default=os.getenv("BASE_URL"),
                     help="OJS Base URL")
    parser.addoption("--ojs-user", action="store", default=os.getenv("OJS_USER"),
                     help="OJS username for authentication")
    parser.addoption("--ojs-pass", action="store", default=os.getenv("OJS_PASS"),
                     help="OJS password for authentication")
    parser.addoption("--theme", action="store", default=os.getenv("FRONTEND_THEME", "Default"),
                     help="Frontend theme to use for testing", choices=["Default", "Immersion"])
    parser.addoption("--existing_plugin", action="store", default=os.getenv("EXISTING_PLUGIN_NAME", "Default Theme"),
                     help="Specify the name of an existing plugin to check for in the plugin gallery")
    parser.addoption("--ojs-version", action="store", default=os.getenv("OJS_VERSION", "3.3"),
                     help="OJS version to use for testing")
    parser.addoption("--ojs-language", action="store", default=os.getenv("OJS_LANGUAGE", None),
                     help="Language to use for testing, required for OJS 3.5 (Backend Tests)")


