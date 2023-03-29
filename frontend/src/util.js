import Swal from 'sweetalert2'
import { marked } from 'marked'
import parseHTML from 'html-react-parser'

const BASE_URL = "/api/v1"

export function apiRequest(endpoint, method, data) {
    return new Promise((resolve, reject) => {
        fetch(`${BASE_URL}/${endpoint}`, {
            method: method?.toUpperCase() ?? 'GET',
            body: data ? JSON.stringify(data) : null,
            headers: method?.toUpperCase() === 'POST' ? {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            } : {
                'Accept': 'application/json'
            }
        }).catch(
            err => reject("An error occurred while making the request")
        ).then(res => {
            if (res?.status === 401)
                reject("You need to be logged in to perform this action")
            else if (res?.status === 403)
                reject("You are not authorized to perform this action")
            else if (res?.status === 404)
                reject("The requested resource was not found")
            else if (res?.status === 409)
                reject("You have already voted!")
            else if (res?.status === 500)
                reject("An internal server error occurred")
            else
                res?.json().catch(
                    err => reject("An error occurred while making the request")
                ).then(data => resolve(data))
        })
    })
}

export function parseMarkdown(input) {
    return parseHTML(marked.parse(input));
}

export function parseMd(input) {
    return marked.parse(input);
}

export function firstUpper(string) {
    return string.charAt(0).toUpperCase() + string.slice(1)
}

export function formToDict(form, extraData) {
    var formData = form ? Object.assign(...Array.from(new FormData(form).entries(), ([x, y]) => ({ [x]: y }))) : {}
    if (extraData)
        Object.keys(extraData).forEach(key => formData[key] = extraData[key])
    return formData
}

export function myAlert(icon, title, text) {
    Swal.fire({
        icon: icon ?? null,
        title: title,
        html: text ?? null,
        showConfirmButton: false,
        timer: (text != null && text.length) > 44 ? 4000 : 2000,
        timerProgressBar: true
    })
}

export function swalInput(title, text, input_type, confirm_text, promise) {
    return new Promise((resolve, reject) => Swal.fire({
        title: title ?? 'Input data here',
        text: text ?? null,
        input: input_type ?? 'text',
        inputAttributes: {
            autocapitalize: 'off'
        },
        showCancelButton: true,
        reverseButtons: true,
        customClass: {
            confirmButton: 'btn btn-primary ms-2',
            cancelButton: 'btn btn-secondary me-2',
            loader: 'spinner-border spinner-border-sm'
        },
        loaderHtml: '<span class="visually-hidden">Loading...</span>',
        buttonsStyling: false,
        confirmButtonText: confirm_text ?? 'Submit',
        showLoaderOnConfirm: true,
        backdrop: true,
        inputValidator: (value) => {
            if (!value)
                return 'Please fill the input'
        },
        preConfirm: (input) => {
            if (promise)
                return promise(input).then(Swal.close)
                    .catch(_ => Swal.showValidationMessage("Incorrect password"))
            else
                resolve(input)
        },
        allowOutsideClick: () => !Swal.isLoading()
    }))
}

export function plural(number) {
    return number === 1 ? '' : 's';
}

export function dateAsString(date) {
    return (date.getDate() < 10 ? "0" : "") + date.getDate() + '/' + (date.getMonth() < 9 ? "0" : "") + (date.getMonth() + 1) + '/' + date.getFullYear();
}

export function hourAsString(date) {
    return (date.getHours() < 10 ? "0" : "") + date.getHours() + ':' + (date.getMinutes() < 10 ? "0" : "") + date.getMinutes();
}

export function readableDateDiff(date, wrt) {
    if (!wrt)
        wrt = new Date();
    if (date === null || date === '')
        return 'never';
    if (!(date instanceof Date))
        date = new Date(date);
    if (!(wrt instanceof Date))
        wrt = new Date(wrt);
    let diff = Math.floor((wrt - date) / 1000),
        pre = diff < 0 ? 'in ' : '',
        pos = diff < 0 ? '' : ' ago';
    if (Math.abs(diff) < 2)
        return "just now";
    else if (Math.abs(diff) < 60)
        return pre + Math.abs(diff) + ' second' + plural(diff) + pos;
    diff = Math.floor(diff / 60);
    if (Math.abs(diff) < 60)
        return pre + Math.abs(diff) + ' minute' + plural(diff) + pos;
    diff = Math.floor(diff / 60);
    if (Math.abs(diff) < 12)
        return pre + Math.abs(diff) + ' hour' + plural(diff) + pos;
    let day_diff = Math.abs(Math.round((new Date(wrt).setHours(12) - new Date(date).setHours(12)) / 8.64e7));
    return (day_diff === 0 ? 'today' : day_diff === 1 ? (diff < 0 ? 'tomorrow' : 'yesterday') : ('on ' + dateAsString(date))) + ' at ' + hourAsString(date);
}
