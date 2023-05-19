resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "properties" = {
            "Interval" = {
                "type" = "string"
            },
            "QueueID" = {
                "type" = "string"
            }
        },
        "type" = "object"
    })
    contract_output = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "properties" = {
            "count" = {
                "type" = "number"
            }
        },
        "type" = "object"
    })
    
    config_request {
        request_template     = "{\n  \"interval\": \"$${input.Interval}\",\n  \n  \"groupBy\": [\n    \"queueId\"\n  ],\n  \"metrics\": [\n    \"nOffered\"\n  ],\n  \"filter\": {\n    \"type\": \"and\",\n    \"predicates\": [\n      {\n        \"dimension\": \"queueId\",\n        \"value\": \"$${input.QueueID}\"\n      },\n      {\n        \"dimension\": \"mediaType\",\n        \"value\": \"voice\"\n      }\n    ]\n  }\n}"
        request_type         = "POST"
        request_url_template = "/api/v2/analytics/conversations/aggregates/query"
        
    }

    config_response {
        success_template = "{\r\n\"count\": $${successTemplateUtils.firstFromArray(\"$${count}\")}\r\n}"
        translation_map = { 
			count = "$.results[?(@.group.mediaType=='voice')].data[0].metrics[?(@.metric=='nOffered')].stats.count"
		}
        translation_map_defaults = {       
			count = "[0].[0]"
		}
    }
}