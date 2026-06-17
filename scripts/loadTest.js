import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
    stages: [
        { duration: '1m', target: 10 },  // ramp-up
        { duration: '2m', target: 50 },  // sustained load
        { duration: '1m', target: 0 },   // ramp-down
    ],
};

export default function () {
    const url = 'http://k8s-cloudmar-frontend-48db514dad-286419167.ap-south-1.elb.amazonaws.com/api/products';

    const res = http.get(url);

    check(res, {
        'status is 200': (r) => r.status === 200,
    });

    sleep(1);
}