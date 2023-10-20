              $output = @()
              # Get all galleries in the subscription
              $allGalleries = Get-AzGallery

              foreach ($gallery in $allGalleries) {
                  $galleryName = $gallery.Name
                  $resourceGroupName = $gallery.ResourceGroupName

                  $imageDefinitions = Get-AzGalleryImageDefinition -ResourceGroupName $resourceGroupName -GalleryName $galleryName

                  foreach ($imageDef in $imageDefinitions) {
                      $imageVersions = Get-AzGalleryImageVersion -ResourceGroupName $resourceGroupName -GalleryName $galleryName -GalleryImageDefinitionName $imageDef.Name
                      $latestVersion = $imageVersions | Sort-Object -Property Name -Descending | Select-Object -First 1

                      $replicationDetails = $latestVersion.PublishingProfile.TargetRegions

                      foreach ($detail in $replicationDetails) {
                          $obj = [PSCustomObject]@{
                              'ResourceGroupName'    = $resourceGroupName
                              'GalleryName'          = $galleryName
                              'ImageName'            = $imageDef.Name
                              'LatestVersion'        = $latestVersion.Name
                              'TargetRegion'         = $detail.Name
                              'RegionalReplicaCount' = $detail.RegionalReplicaCount
                              'StorageAccountType'   = $detail.StorageAccountType
                              'ProvisioningState'    = $latestVersion.ProvisioningState
                          }
                          $output += $obj
                      }
                  }
              }

              $output | Format-Table -AutoSize
