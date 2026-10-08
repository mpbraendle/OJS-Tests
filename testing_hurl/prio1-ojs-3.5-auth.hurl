# prio 1 test for OJS 3.3 that require authentication

# Get the (redirected) query_url
GET {{BASE_URL}}
[Options]
location:true # follow redirects
# output: out.html # output response to file
HTTP 200
[Captures]
query_url: url # we store the url returned by the server so rewrites on the server side will be considered
query_url_no_locale: url regex /(.*).../ # Remove the locale part from the url
[Asserts]
variable "query_url" != ""

# Get csrf_token
GET {{query_url}}/login
[Options]
location:true # follow redirects
HTTP 200
[Captures]
csrf_token: xpath "string(//meta[@name='csrf-token']/@content)"
[Asserts]
variable "csrf_token" != ""

# ID 17 - Standard OJS login in BE possible
# Login
POST {{query_url}}/login/signIn
[Options]
location:true # follow redirects
[Form]
csrfToken: {{csrf_token}}
username: {{TEST_USERNAME}}
password: {{SECRET_TEST_PASSWORD}}
HTTP 200
[Asserts]
# uncomment for debugging authentication issues
# xpath "/" == "{{TEST_USERNAME}}"
# xpath "/" == "{{SECRET_TEST_PASSWORD}}"
xpath "string(//div[@class='pkp_form_error'])" == "" # we check that there is no error message displayed

# Check we are logged in
GET {{query_url}}/dashboard/editorial
X-CSRF-TOKEN: {{csrf_token}}
[Options]
location:true # follow redirects
HTTP 200
[Asserts]
xpath "string(//body/@class)" startsWith "pkp_page_dashboard" # This will work work generally as it does compare string values

# ID 20 - Plugin gallery accessible
# Plugin Gallery
GET {{query_url}}/management/settings/website\#pluginGallery
X-CSRF-TOKEN: {{csrf_token}}
[Options]
location:true # follow redirects
HTTP 200
[Asserts]
xpath "string(//div[@class='app__page width'])" contains "div#pluginGalleryGridContainer" # This div contains javascript code, not the rendered HTML page
# Fetch the plugin gallery table directly
GET {{query_url_no_locale}}/$$$call$$$/grid/plugins/plugin-gallery-grid/fetch-grid
# GET https://zgd-journal.de/index.php/zgd/$$$call$$$/grid/plugins/plugin-gallery-grid/fetch-grid
X-CSRF-TOKEN: {{csrf_token}}
[Options]
location:true # follow redirects
HTTP 200
[Asserts]
jsonpath "$..content" nth 0 contains "cell-0-name" # We test that fetch grid returned at least one row

# ID 21 - Issue: overview in BE accessible
# Ausgabenseite lässt sich aufrufen
GET {{query_url}}/manageIssues
X-CSRF-TOKEN: {{csrf_token}}
[Options]
location:true # follow redirects
HTTP 200
[Asserts]
xpath "string(//body/@class)" startsWith "pkp_page_manageIssues"

# ID 22/23 - Website settings: plugin list accessible and a specific plugin (defaultthemeplugin) is present
# Liste der plugins lässt sich aufrufen
GET {{query_url_no_locale}}/$$$call$$$/grid/settings/plugins/settings-plugin-grid/fetch-grid
X-CSRF-TOKEN: {{csrf_token}}
[Options]
location:true # follow redirects
HTTP 200
[Asserts]
jsonpath "$..content" nth 0 contains "component-grid-settings-plugins-settingsplugingrid-category-themes-row-defaultthemeplugin"

# ID 25 - Statistics: overview accessible, table contents present
# Artikelstatistik lässt sich aufrufen
GET {{query_url_no_locale}}/stats/publications/publications
X-CSRF-TOKEN: {{csrf_token}}
[Options]
location:true # follow redirects
HTTP 200
[Asserts]
xpath "//div[@class='pkpStats']" exists
GET {{query_url_no_locale}}/api/v1/stats/publications?count=30&offset=0&dateStart=2025-05-01
X-CSRF-TOKEN: {{csrf_token}}
[Options]
location:true # follow redirects
HTTP 200
[Asserts]
jsonpath "$.items" count > 0 # we check that there are items in the response

# ID 26 - Submissions: overview accessible
# Einreichungsübersicht lässt sich aufrufen
GET {{query_url}}/dashboard/editorial?currentViewId=active
X-CSRF-TOKEN: {{csrf_token}}
[Options]
location:true # follow redirects
HTTP 200
[Asserts]
xpath "//div[@class='app__page width width--full']" exists

# ID 27 - User management: overview accessible
GET {{query_url}}/management/settings/access
X-CSRF-TOKEN: {{csrf_token}}
[Options]
location:true # follow redirects
HTTP 200
[Asserts]
xpath "string(//*[@id='userGridContainer']/div/table/tbody/tr)" exists # we check that there is at least one user in the user list

# ID 28 - Administration page accessible
GET {{query_url}}/admin
X-CSRF-TOKEN: {{csrf_token}}
[Options]
location:true # follow redirects
HTTP 200

# ID 29 - System information accessible (check specific entries if applicable)
GET {{query_url}}/admin/systemInfo
X-CSRF-TOKEN: {{csrf_token}}
[Options]
location:true # follow redirects
HTTP 200