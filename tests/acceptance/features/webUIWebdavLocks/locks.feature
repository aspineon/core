@webUI @insulated @disablePreviews
Feature: Locks
  As a user
  I would like to be able to delete locks of files and folders
  So that I can access files with locks that have not been cleared

  Background:
    #do not set email, see bugs in https://github.com/owncloud/core/pull/32250#issuecomment-434615887
    Given these users have been created:
      |username      |
      |brand-new-user|
    And user "brand-new-user" has logged in using the webUI

  Scenario: setting a lock shows the lock symbols at the correct files/folders
    Given the user "brand-new-user" has locked the folder "simple-folder" setting following properties
      | lockscope | shared |
    And the user "brand-new-user" has locked the file "data.zip" setting following properties
      | lockscope | exclusive |
    When the user browses to the files page
    Then the folder "simple-folder" should be marked as locked on the webUI
    And the folder "simple-folder" should be marked as locked by user "brand-new-user" in the locks tab of the details panel on the webUI
    But the folder "simple-empty-folder" should not be marked as locked on the webUI
    And the file "data.zip" should be marked as locked on the webUI
    And the file "data.zip" should be marked as locked by user "brand-new-user" in the locks tab of the details panel on the webUI
    But the file "data.tar.gz" should not be marked as locked on the webUI

  Scenario: lock set on a shared file shows the lock information for all involved users
    Given these users have been created:
      |username  |
      |sharer    |
      |receiver  |
      |receiver2 |
    And group "receiver-group" has been created
    And user "receiver2" has been added to group "receiver-group"
    And user "sharer" has shared file "data.zip" with user "receiver"
    And user "sharer" has shared file "data.tar.gz" with group "receiver-group"
    And user "receiver" has shared file "data (2).zip" with user "brand-new-user"
    And the user "sharer" has locked the file "data.zip" setting following properties
      | lockscope | shared |
    And the user "receiver" has locked the file "data (2).zip" setting following properties
      | lockscope | shared |
    And the user "brand-new-user" has locked the file "data (2).zip" setting following properties
      | lockscope | shared |
    And the user "receiver2" has locked the file "data.tar (2).gz" setting following properties
      | lockscope | shared |
    When the user browses to the files page
    Then the file "data (2).zip" should be marked as locked on the webUI
    And the file "data (2).zip" should be marked as locked by user "sharer" in the locks tab of the details panel on the webUI
    And the file "data (2).zip" should be marked as locked by user "receiver" in the locks tab of the details panel on the webUI
    And the file "data (2).zip" should be marked as locked by user "brand-new-user" in the locks tab of the details panel on the webUI
    But the file "data.zip" should not be marked as locked on the webUI
    When the user re-logs in as "sharer" using the webUI
    Then the file "data.zip" should be marked as locked on the webUI
    And the file "data.zip" should be marked as locked by user "sharer" in the locks tab of the details panel on the webUI
    And the file "data.zip" should be marked as locked by user "receiver" in the locks tab of the details panel on the webUI
    And the file "data.zip" should be marked as locked by user "brand-new-user" in the locks tab of the details panel on the webUI
    And the file "data.tar.gz" should be marked as locked on the webUI
    And the file "data.tar.gz" should be marked as locked by user "receiver2" in the locks tab of the details panel on the webUI
    When the user re-logs in as "receiver2" using the webUI
    Then the file "data.tar (2).gz" should be marked as locked on the webUI
    And the file "data.tar (2).gz" should be marked as locked by user "receiver2" in the locks tab of the details panel on the webUI

  Scenario: setting a lock on a folder shows the symbols at the sub-elements
      Given the user "brand-new-user" has locked the folder "simple-folder" setting following properties
       | lockscope | shared |
      When the user opens the folder "simple-folder" using the webUI
      Then the folder "simple-empty-folder" should be marked as locked on the webUI
      And the folder "simple-empty-folder" should be marked as locked by user "brand-new-user" in the locks tab of the details panel on the webUI
      And the file "data.zip" should be marked as locked on the webUI
      And the file "data.zip" should be marked as locked by user "brand-new-user" in the locks tab of the details panel on the webUI

  Scenario: setting a depth:0 lock on a folder does not shows the symbols at the sub-elements
      Given the user "brand-new-user" has locked the folder "simple-folder" setting following properties
       | depth | 0 |
      When the user browses to the files page
      Then the folder "simple-folder" should be marked as locked on the webUI
      When the user opens the folder "simple-folder" using the webUI
      Then the folder "simple-empty-folder" should not be marked as locked on the webUI
      And the file "data.zip" should not be marked as locked on the webUI

  Scenario: unlocking by webDAV deletes the lock symbols at the correct files/folders
      Given the user "brand-new-user" has locked the folder "simple-folder" setting following properties
       | lockscope | shared |
      When the user "brand-new-user" unlocks the last lock of the folder "simple-folder" using the WebDAV API
      And the user browses to the files page
      Then the folder "simple-folder" should not be marked as locked on the webUI
      
#  Scenario: delete the only remaining lock deletes the lock symbol
#  Scenario: delete a lock that was created by an other user results in an error
#  Scenario: delete an exclusive lock of a file
#  Scenario: delete an exclusive lock of a folder
#  Scenario: delete an exclusive lock of a folder by deleting it from a file in the folder
#  Scenario: delete the first shared lock of a file
#  Scenario: delete the second shared lock of a file
#  Scenario: delete the last shared lock of a file
#  Scenario: delete the first shared lock of a folder
#  Scenario: delete the second shared lock of a folder
#  Scenario: delete the last in shared lock of a folder
#  Scenario: delete/upload/rename/move a locked file gives a nice error message
#  Scenario: unshare locked folder/file
#  Scenario: decline/accept locked folder/file
#  Scenario: correct displayname / username is shown in the lock list
#  Scenario: new files in a locked folder get locked
