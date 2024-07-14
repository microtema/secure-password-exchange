const AWS = require('aws-sdk');

module.exports.handler = async (event) => {

    const region = process.env.REGION
    const TableName = process.env.TABLE_NAME;

    // Set the region
    AWS.config.update({region});

    const docClient = new AWS.DynamoDB.DocumentClient();

    const params = {
        TableName,
        Key: {...event.pathParameters}
    }

    await docClient.delete(params).promise()

    return {
        statusCode: 200,
        headers: {"content-type": "application/json"},
        body: JSON.stringify({message: "Password successfully deleted!"}),
    }
}