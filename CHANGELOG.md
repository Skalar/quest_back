## 0.0.2 (unreleased)
* Support for operation `add_respondents_data_with_sms_invitation`.

## 0.0.1
* Added `QuestBack.debug!` option. Does not send request, logs generated XML.
* Basic operations `test_connection`, `get_quests`, `get_language_list`,
  `add_email_invitees` and `add_respondents_data`.
* Simple `QuestBack::Response` object for wrapping Savon's response and
  provide an interface for reading out response's `result` or `results`.
* Configuration and authentication.
