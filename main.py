import json
import os

import git

repo = git.Repo(search_parent_directories=True)
git_root = repo.git.rev_parse("--show-toplevel")
print("Git root directory:", git_root)

print("running..")
os.system(
    "firefox -new-tab about:config?filter=browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines & google"
)
