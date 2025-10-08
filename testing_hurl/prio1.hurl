# prio 1 test for OJS 3.3

# ID 1 - A static page exist (e.g. OJS homepage) & displaying the desired content
# Also store the URL returned by the server to consider possible rewrites on the server side
GET {{BASE_URL}}
[Options]
location:true # follow redirects
HTTP 200
[Captures]
query_url: url # we store the url returned by the server so rewrites on the server side will be considered
[Asserts]
xpath "//div[@class='pkp_structure_page']" exists # this selects all divs with exactly this class and will only work if pkp_structure_page is the only class assinged to this div

# ID 2 - Display current journal issue
# Also capture the first article URL and the gallery URL from the current issue page for later use
GET {{query_url}}/issue/current
[Options]
location:true # follow redirects
HTTP 200
[Captures]
article_url: xpath "normalize-space(//a[starts-with(@id, 'article')][1]/@href)" # we capture the first article URL from the current issue"
galley_url: xpath "normalize-space(//a[contains(@class, 'obj_galley_link')]/@href)" # we capture the gallery URL
[Asserts]
variable "article_url" != ""
variable "galley_url" != ""

# ID 3 - Display Article detail page
GET {{article_url}}
[Options]
location:true # follow redirects
HTTP 200

# ID 4 - Display journal archive
GET {{query_url}}/issue/archive
[Options]
location:true # follow redirects
HTTP 200

# ID 6 - Display galley of an article
GET {{galley_url}}
[Options]
location:true # follow redirects
HTTP 200

# ID 9 - Display main navigation (including sub menus)
GET {{article_url}}
[Options]
location:true # follow redirects
HTTP 200
[Captures]
navigation_xpath: xpath "//div[@class='pkp_navigation_primary_wrapper']"
[Asserts]
variable "navigation_xpath" count == 1 # we check that the navigation is present

# ID 12 - Sidebar/Footer available
GET {{article_url}}
[Options]
location:true # follow redirects
HTTP 200
[Captures]
sidebar_xpath: xpath "//div[@class='pkp_structure_sidebar left']"
footer_xpath: xpath "//div[@class='pkp_structure_footer']"
[Asserts]
variable "sidebar_xpath" count >= 1 # we check that the sidebar is present
variable "footer_xpath" count >= 1 # we check that the footer is present

# ID 14 - Search page is present
GET {{query_url}}/search
[Options]
location:true # follow redirects
HTTP 200
[Asserts]
xpath "//div[@class='search_input']" exists