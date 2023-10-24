# Define the path to the Chrome Bookmarks file for the default profile
$chromeBookmarksPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks"
$edgeBookmarksPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Bookmarks"

# Check if the Chrome bookmarks file exists
if (Test-Path $chromeBookmarksPath) {
    # Read the content of the Chrome bookmarks file and convert it to a PowerShell object
    $chromeBookmarksData = Get-Content -Path $chromeBookmarksPath | ConvertFrom-Json

    # Extract bookmarks from the object recursively
    function Extract-Bookmarks {
        param (
            $node
        )

        # Base case: If the node has a URL, it's a bookmark
        if ($node.url) {
            [PSCustomObject]@{
                Type = "url"
                Name  = $node.name
                URL   = $node.url
            }
        } else {
            # Recursive case: If it's a folder, check its children
            $folder = [PSCustomObject]@{
                Type = "folder"
                Name = $node.name
                Children = @()
            }

            foreach ($child in $node.children) {
                $folder.Children += Extract-Bookmarks -node $child
            }
            $folder
        }
    }

    # Extract Chrome bookmarks
    $exportedBookmarks = $chromeBookmarksData.roots.psobject.Properties | ForEach-Object {
        Extract-Bookmarks -node $_.Value
    }

    # Check if the Edge bookmarks file exists
    if (Test-Path $edgeBookmarksPath) {
        $edgeBookmarksData = Get-Content -Path $edgeBookmarksPath | ConvertFrom-Json

        # Append exported bookmarks to Edge's bookmarks
        foreach ($bookmark in $exportedBookmarks) {
            $edgeBookmarksData.roots.bookmark_bar.children += $bookmark
        }

        # Write the combined bookmarks back to Edge's bookmark file
        $edgeBookmarksData | ConvertTo-Json -Depth 100 | Set-Content -Path $edgeBookmarksPath

        Write-Output "Bookmarks imported to Edge successfully!"
    } else {
        Write-Error "Could not find the Edge bookmarks file at $edgeBookmarksPath."
    }
} else {
    Write-Error "Could not find the Chrome bookmarks file at $chromeBookmarksPath."
}
