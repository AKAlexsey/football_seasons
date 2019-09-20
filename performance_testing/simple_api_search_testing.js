import http from "k6/http"
import { getEnvironmentHost, getEnvironmentPort, sendRequest, searchParams } from './utils/request.js'

const host = getEnvironmentHost();
const port = getEnvironmentPort();
const params = searchParams();

export default function() {
    sendRequest(host, port, '/api/db_seasons/search', params);
    return true;
}
