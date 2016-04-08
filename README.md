# QuestBack

Simple Ruby client for QuestBack's SOAP API.

![Codeship build status](https://codeship.com/projects/74070280-df99-0133-54e5-460ef9277ccd/status?branch=master)

### WARNING

This gem is not complete and may lack many functions provided by QuestBack.
Please feel free to contribute and make pull requests.

It is also very simplistic, only using simple hashes for both sending in arguments to the API and returning responses.
The hash you send as argument to an operation methods is more or less passed on directly to QuestBack. We do some
transformation of the has to match the expectations of QuestBack's API.




## Installation

Add this line to your application's Gemfile:

    gem 'quest_back'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install quest_back

## Usage

### Getting access to API

1. Go to https://response.questback.com/soapdocs/integration/ and request white listing of the IP you will make requests from.
2. Sign in to QuestBack. Go to your account's page and fill in "Integration username and password".
   If you have no fields under Integration Information you have to contact QuestBack to get access.

### Create an API client

```ruby
api = QuestBack::Api.new(
  config: QuestBack::Configuration.new(username: "username", password: "password")
)

response = api.test_connection
response.result
=> "Connection sucessful. you are connected to namespace: https://integration.questback.com/2011/03"
```

### Examples

```ruby
# Read quests
api = QuestBack::Api.new
response = api.get_quests
irb(main):005:0> response.results
=> [
    {
      :quest_id=>"4567668",
      :security_lock=>"m0pI8orKJp",
      :quest_title=>"Skalars spørreundersøkelse",
      ...
    },
    {
      ...
    }
  ]


# Add email invitees
response = api.add_email_invitees(
  quest_info: {quest_id: 4567668, security_lock: 'm0pI8orKJp'},
  emails: ['inviso@skalar.no', 'th@skalar.no'],
  sendduplicate: true
)

response.result
=> "Added 2 invitations to QuestId:4567668"


# Add respondent data
response = api.add_respondents_data(
  quest_info: {quest_id: 4567668, security_lock: 'm0pI8orKJp'},
  respondents_data: {
    respondent_data_header: {
      respondent_data_header: [
        {
          title: 'Epost',
          type: QuestBack::Api.respondent_data_header_type_for(:text),
          is_email_field: true,
          is_sms_field: false
        },
        {
          title: 'Navn',
          type: QuestBack::Api.respondent_data_header_type_for(:text),
          is_email_field: false,
          is_sms_field: false
        },
        {
          title: 'Alder',
          type: QuestBack::Api.respondent_data_header_type_for(:numeric),
          is_email_field: false,
          is_sms_field: false
        },
      ]
    },
    respondent_data: ['th@skalar.no;Thorbjorn;32'],
    allow_duplicate: true,
    add_as_invitee: true
  }
)

response.result
=> "Added 1 respondent data to QuestId :4567668"


# Add respondent data with sms invitation
response = api.add_respondents_data_with_sms_invitation(
  quest_info: {quest_id: 4567668, security_lock: 'm0pI8orKJp'},
  respondents_data: {
    respondent_data_header: {
      respondent_data_header: [
        {
          title: 'Phone',
          type: QuestBack::Api.respondent_data_header_type_for(:text),
          is_email_field: false,
          is_sms_field: true
        }
      ]
    },
    respondent_data: ['4711223344'],
    allow_duplicate: true,
    add_as_invitee: true
  },
  sms_from_number: 11111111,
  sms_from_text: 'Inviso AS',
  sms_message: 'Hello - please join our quest!'
)

response.result
=> "Sms message created successfully"
```

### Debug XML without making a request

If you ever need to see XML generated without sending the request it can be done by doing:

```ruby
QuestBack.debug!
QuestBack::Api.new.test_connection

  DEBUG -- : HTTPI GET request to integration.questback.com (net_http)
   INFO -- : !!!!!!!!!
   INFO -- : !!! SOAP request hijacked by QuestBack::DebugObserver.
   INFO -- : !!!!!!!!!
  DEBUG -- :

  <?xml version="1.0" encoding="UTF-8"?>
  <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:wsdl="https://integration.questback.com/2011/03" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:array="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns:enum="http://schemas.microsoft.com/2003/10/Serialization/Enums">
    <env:Body>
      <wsdl:TestConnection>
        <wsdl:userInfo>
          <wsdl:Username>inviso@skalar.no</wsdl:Username>
          <wsdl:Password>xxxxx</wsdl:Password>
        </wsdl:userInfo>
      </wsdl:TestConnection>
    </env:Body>
  </env:Envelope>

QuestBack.remove_debug! # Activates real requests again
```



## Contributing

1. Fork it (https://github.com/Skalar/quest_back/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

#### Test client in console

After cloning the repository you may do this to make it a bit more convenient working
with the code in your console while developing.

1. Copy config.example.yml to config.yml and insert your username and password.
2. Load console `bundle console` and do `QuestBack.conf!` to load config.yml as default config.
3. `QuestBack::Client.new.test_connection` to make a test connection API call. On successful connection this returns string with current namespace of integration library.
