const AWS = require('aws-sdk');
const {uuid} = require('uuidv4');

module.exports.handler = async (event) => {

    const region = process.env.REGION
    const TableName = process.env.TABLE_NAME;

    // Set the region
    AWS.config.update({region});

    const docClient = new AWS.DynamoDB.DocumentClient();

    const Item = JSON.parse(event.body);

    // assign unique id
    Item.id = uuid()

    const params = {TableName, Item}

    await docClient.put(params).promise();

    return {
        statusCode: 201,
        headers: {"content-type": "application/json"},
        body: JSON.stringify({id: Item.id})
    }
}