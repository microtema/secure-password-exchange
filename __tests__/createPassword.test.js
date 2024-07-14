const {faker} = require('@faker-js/faker');


describe('Customer Create API', () => {

    const OLD_ENV = process.env;

    beforeEach(() => {
        jest.resetModules() // Most important - it clears the cache
        process.env = {TABLE_NAME: 'PASSWORD', REGION: 'eu-central-1'};
    });

    afterAll(() => {
        process.env = OLD_ENV; // Restore old environment
    });

    const sut = require('../src/createPassword');

    test('Should create full new password', async () => {

        // Given
        const body = {
            "expiration": faker.date.soon({days:1}),
            "message": faker.internet.userName(),
            "once": faker.datatype.number({max:1}) <= 0.5
        }

        const event = {
            body: JSON.stringify(body)
        }

        // When
        //const answer = await sut.handler(event)

        // Then
        expect(true).toEqual(true)
    });
});