import {
    Link,
    useNavigate
} from "react-router-dom";
import {
    useState,
    useEffect,
    createRef
} from 'react';
import {
    readableDateDiff,
    myAlert,
    firstUpper,
    apiRequest
} from '../util.js'
import Swal from 'sweetalert2'

export function Spinner(props) {
    return (
        <div className={`${props.centered ?? true ? 'd-flex justify-content-center my-5' : 'mx-3 d-inline-block'}`}>
            <div className={`spinner-border${(props.small ?? false) ? ' spinner-border-sm' : ''}`} role="status">
                <span className="visually-hidden">Loading...</span>
            </div>
        </div>
    )
}

export function TextMuted(props) {
    return (
        <div className="text-center my-5 text-muted">
            {props.children}
        </div>
    )
}

export function CardAction(props) {
    return (
        <Link to={props.to ?? ''} className={`btn btn-${props.btnClass ?? 'primary'} rounded-bottom`} onClick={props.onClick ?? null}>
            {props.icon && <i className={`bi bi-${props.icon} me-2`}></i>}
            {props.text}
        </Link>
    )
}

export function CardCollection(props) {
    return ((props.cards ?? {}).length === 0 ? <TextMuted>{props.empty_msg ?? "Nothing to see here!"}</TextMuted> :
        <div className="row">
            {props.cards.map(item => (
                <div className="col-md-6 col-lg-4" key={item.key}>
                    <div className="card my-3">
                        <Link to={item.link} className="text-dark hoverable text-decoration-none">
                            <div className="card-header">
                                <h2 className="m-0">
                                    {item.icon && <i className={`bi bi-${item.icon} me-2`}></i>}
                                    {item.title}
                                </h2>
                                {item.subtitle ? <span className="text-muted p-0">{item.subtitle}</span> : ''}
                            </div>
                            <div className="card-body fade-overflow">
                                {item.descr}
                            </div>
                        </Link>
                        {item.actions && (
                            <div className="btn-group rounded-bottom bg-primary">
                                {item.actions}
                            </div>
                        )}
                    </div>
                </div>
            ))}
        </div>
    );
}

export function Loader(props) {
    var box = createRef();
    const [style, setStyle] = useState({});
    const [loadingPriv, setLoading] = useState(false);

    useEffect(() => {
        if (box.current) {
            setStyle({
                width: `${box.current.offsetWidth}px`,
                height: `${box.current.offsetHeight}px`,
                whiteSpace: 'nowrap',
                padding: '0 6px'
            });
            setLoading(props.loading);
        }
    }, [props.loading, box]);

    if (props.keepSize ?? true)
        return <div style={(loadingPriv ?? false) ? style : {}} ref={box}>
            {!(loadingPriv ?? false) ? props.children :
                <div className="spinner-border spinner-border-sm" role="status">
                    <span className="visually-hidden">Loading...</span>
                </div>
            }
        </div>
    else
        return !(loadingPriv ?? false) ? props.children :
            <div className="spinner-border spinner-border-sm" role="status">
                <span className="visually-hidden">Loading...</span>
            </div>
}


export function PromiseLoader(props) {
    const [loading, setLoading] = useState(false);
    return <button title={props.btnTitle ?? null} className={props.btnClass ?? 'btn btn-primary'} onClick={() => {
        setLoading(true);
        if (props.promise)
            props.promise().then(() => setLoading(false));
        else if (props.function)
            props.function();
        else
            throw Error("No action associated to the button");
    }} role={props.role ?? 'button'} ref={props.btnRef ?? null} disabled={props.disabled || loading}>
        <Loader loading={loading} keepSize={props.keepSize ?? true}>{props.children}</Loader>
    </button>
}


export function confirmDelete(apiEndpoint, alertBody, callback) { // It's possible replacing the callback by a promise
    Swal.fire({
        title: 'Are you sure?',
        text: alertBody ?? 'The requested resource will be permanently deleted. Procceed?',
        icon: 'warning',
        showCancelButton: true,
        customClass: {
            confirmButton: 'btn btn-danger ms-2',
            cancelButton: 'btn btn-secondary me-2',
            loader: 'spinner-border spinner-border-sm'
        },
        buttonsStyling: false,
        confirmButtonText: 'Confirm',
        reverseButtons: true,
        showLoaderOnConfirm: true,
        loaderHtml: '<span className="visually-hidden">Loading...</span>',
        preConfirm: () => {
            apiRequest(apiEndpoint, 'DELETE')
                .then(
                    (result) => {
                        callback();
                        myAlert('success', 'Deleted successfully!');
                    },
                    (error) => {
                        console.log(error);
                    }
                )
        }
    });
}

export function ClearFix() {
    return <div className="d-block m-0 p-0"></div>
}

export function Redirect(props) {
    const navigate = useNavigate();
    useEffect(() => {
        navigate(props.to ?? '/', props.replace ? { replace: props.replace } : {});
    }, [navigate, props.replace, props.to]);
}

export function LeftRightDivs(props) {
    return <div className="d-flex justify-content-between align-items-center">{props.children}</div>
}

export function Icon(props) {
    return <i className={`bi bi-${props.name} me-${props.me ?? 0}`}></i>
}

export function TitleWithButtonBack(props) {
    const navigate = useNavigate();
    return <div className={`mb-${props.mb ?? '3'}`}>
        {props.to
            ? <Link to={props.to} className="btn btn-primary" style={{ marginTop: '-20px' }}><Icon name="arrow-left" me="2" />{props.text || "Go back"}</Link>
            : <button type="link" onClick={() => navigate(props.href ?? -1)} className="btn btn-primary" style={{ marginTop: '-20px' }}><Icon name="arrow-left" me="2" />{props.text || "Go back"}</button>
        }
        <h1 className='d-inline ms-md-3'>{props.children}</h1>
    </div>
}

export function FormHelp(props) {
    return <p className={`text-muted form-text mt-0 mb-${props.mb ?? 3}`}>
        {props.children}
    </p>
}

export function TimeAgo(props) {
    const [now, setNow] = useState(new Date())
    useEffect(() => {
        setTimeout(() => setNow(new Date()),
            readableDateDiff(props.timestamp).includes('second') || readableDateDiff(props.timestamp).includes('just') ? 1000 : 60000
        )
    }, [now, props.timestamp])
    return (props.firstUpper ?? false) ? firstUpper(readableDateDiff(props.timestamp)) : readableDateDiff(props.timestamp);
}
