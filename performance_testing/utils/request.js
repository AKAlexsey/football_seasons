import http from "k6/http"

const DIVISIONS = ['SP1', 'SP2', 'E0', 'D1'];
const SEASONS = ['201920', '201617', '201516'];

export function getEnvironmentHost() {
    const host = __ENV.HOST;
    return (host ? host : 'localhost');
}

export function getEnvironmentPort() {
    const port = __ENV.PORT;
    return (port ? port : 4001);
}

export function getRandomNumber(maxNumber) {
    return Math.floor(Math.random() * maxNumber);
}

export function randomArrayElement(array) {
    return array[getRandomNumber(array.length)];
}

export function randomDivisionParams() {
    const division = randomArrayElement(DIVISIONS);
    return `?division=${division}`;
}

export function randomSeasonParams() {
    const season = randomArrayElement(SEASONS);
    return `?season=${season}`;
}

export function randomDivisionAndSeasonParams() {
    const season = randomArrayElement(SEASONS);
    const division = randomArrayElement(DIVISIONS);
    return `?season=${season}&division=${division}`;
}

export function sendRequest(host, port, path, params = '') {
    const requestUrl = `http://${host}:${port}${path}${params}`;
    const response = http.get(requestUrl);
    return response;
}

export function searchParams() {
    const randomSearchParamsFunction = randomArrayElement([
        randomDivisionParams,
        randomSeasonParams,
        randomDivisionAndSeasonParams
    ]);
    return randomDivisionAndSeasonParams();
}
