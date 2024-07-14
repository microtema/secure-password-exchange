const AWS = require('aws-sdk');

function capitalize(string) {
    return string.charAt(0).toUpperCase() + string.toLowerCase().slice(1);
}

module.exports.handler = async (event) => {

    const region = process.env.REGION

    // Set the region
    AWS.config.update({region});
    const eventBridge = new AWS.EventBridge()

    const Entries = []

    for (let index = 0; index <= event.Records.length; index++) {

        const record = event.Records[index]

        if (!record) {
            continue;
        }

        const customer = AWS.DynamoDB.Converter.unmarshall(record.dynamodb.NewImage)
        const eventName = 'Password' + capitalize(record.eventName) + 'edEvent'

        Entries.push({
            Detail: JSON.stringify({event: eventName, payload: {id: customer.id}}),
            DetailType: eventName,
            EventBusName: 'default',
            Source: 'dynamodb.event'
        })
    }

    //  await eventBridge.putEvents(events).promise();
    console.log("publish events", {Entries});
}