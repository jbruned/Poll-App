import {
    useState,
    useEffect,
    useRef
} from 'react';
import {
    Link,
    Outlet,
    useNavigate,
    useParams,
    NavLink
} from "react-router-dom";
import {
    readableDateDiff,
    myAlert,
    apiRequest,
    swalInput,
    dateAsString,
    parseMarkdown,
    plural
} from '../util.js'
import {
    Spinner,
    TextMuted,
    CardAction,
    CardCollection,
    Loader,
    PromiseLoader,
    confirmDelete,
    ClearFix,
    LeftRightDivs,
    Icon,
    TitleWithButtonBack,
    FormHelp,
    TimeAgo,
    Redirect
} from './basicComponents.js'

export function Home(props) {
    return <>
        <h1 className='text-center'>Welcome to PollApp</h1>
        <p className="h5 fw-normal text-center">This is what democracy looks like!</p>
        <hr className="mt-4 mb-3" />
        <LeftRightDivs>
            <h2 className="h3">Here are some polls for you</h2>
            <Link to="/polls" className="btn btn-primary"><Icon name="plus-lg" me="2" />Create poll</Link>
        </LeftRightDivs>
        <PollList isAdmin={props.isAdmin} />
    </>
}

export function PollList(props) {

    const [error, setError] = useState(null)
    const [isLoaded, setIsLoaded] = useState(false)
    const [items, setItems] = useState([])

    useEffect(() => {
        apiRequest('polls')
            .then(
                (result) => {
                    setItems(result)
                    setIsLoaded(true)
                },
                (error) => {
                    setError(error)
                    setIsLoaded(true)
                }
            )
    }, [])

    return (
        !isLoaded ? <Spinner /> : (
            error ? <p>{error ?? "Error while fetching the poll list"}</p> :
                <CardCollection cards={items.map(i => ({
                    key: i.id,
                    link: "/polls/" + i.id,
                    title: i.title,
                    descr: <>
                        {/*<p>Created {readableDateDiff(i.timestamp)}</p>
                        <p className='m-3'>*/}
                        <p className='m-2 d-flex flex-column'>
                            <div><Icon name="bar-chart-fill" me="2" />{i.options_count} option{plural(i.options_count)}</div>{/*grid-fill*/}
                            <div><Icon name="people-fill" me="2" />{i.answers_count} answer{plural(i.answers_count)}</div>
                            <div><Icon name="clock-fill" me="2" />Created <TimeAgo timestamp={i.timestamp} /></div>
                        </p>
                    </>,
                    actions: <>
                        <CardAction text="Vote" icon="send-fill" to={`/polls/${i.id}`} />
                        {(i.owned || (props.isAdmin ?? false)) ? <>
                            <CardAction text="Delete" icon="trash3-fill" btnClass="danger" onClick={() => {
                                confirmDelete(`polls/${i.id}`, `'${i.title}' will be permanently deleted`,
                                    () => setItems(items.filter(i2 => i2.id != i.id)))  // TODO refresh instead?
                            }} />
                        </> : null}
                    </>
                }))} empty_msg={props.empty_msg || "No polls have been created (yet)"} />
        )
    )
}

export function Poll(props) {

    const [error, setError] = useState(null)
    const [isLoaded, setIsLoaded] = useState(false)
    const [poll, setPoll] = useState([])
    const params = useParams()
    const [userHasAnswered, setUserHasAnswered] = useState(false)
    const [selectedOption, setSelectedOption] = useState(null)
    const navigate = useNavigate()

    useEffect(() => {
        setIsLoaded(false);
        apiRequest(`poll/${params.poll_id}`)
            .then(
                (result) => {
                    setPoll(result)
                    setIsLoaded(true)
                    setUserHasAnswered(result.user_answer !== undefined && result.user_answer !== null && result.user_answer !== false)
                    setSelectedOption(result.user_answer ?? null)
                },
                (error) => {
                    setError(error)
                    setIsLoaded(true)
                    setUserHasAnswered(false)
                }
            )
    }, [params])

    function doVote() {
        //let selected = document.querySelector('input[name="flexRadioDefault"]:checked')
        if (selectedOption !== null) {
            // let option_id = selected.id.split('-')[1]
            apiRequest(`option/${selectedOption}`, 'POST')
                .then(
                    (result) => {
                        setUserHasAnswered(true)
                    },
                    (error) => {
                        setError(error)
                        setIsLoaded(true)
                        setUserHasAnswered(false)
                    }
                )
        } else
            myAlert("error", "Please select an option")
    }

    return (
        !isLoaded ? <Spinner /> : (
            error ? <p>{error ?? "Error while fetching the requested poll"}</p> : <>
                {userHasAnswered ? <Redirect replace={true} to={`./results`} /> : null}
                <TitleWithButtonBack text="All polls" href="/">{poll.title}</TitleWithButtonBack>
                <p className="m-0 p-0 text-muted">{poll.answers_count} answer{plural(poll.answers_count)} so far | Posted <TimeAgo timestamp={poll.timestamp} /></p>
                {parseMarkdown(poll.content ?? '')}
                <div className='d-flex align-items-center justify-content-center flex-column'>
                    <div className="m-4">
                        {poll.options.length == 0 ? <p>No options have been added yet</p> :
                            poll.options.map(o => <div className="form-check" key={o.id}>
                                <input className="form-check-input" type="radio" name="flexRadioDefault" id={`radio-${o.id}`} disabled={userHasAnswered} checked={selectedOption === o.id} onChange={(e) => {if (e.target.checked) setSelectedOption(o.id)}} />
                                <label className="form-check-label" htmlFor={`radio-${o.id}`}>{o.text}</label>
                            </div>)
                        }
                    </div>
                    <button type="button" className={`btn btn-primary btn-lg${userHasAnswered || selectedOption === null ? " disabled" : ""}`} onClick={doVote}>
                        <Icon name="send-fill" me="2" />Submit vote
                    </button>
                </div>
                <p className='text-center mt-1' style={{fontSize: 'smaller'}}><Link to="./results">View results</Link></p>
            </>
        )
    )
}

export function EditPoll(props) {

    const [error, setError] = useState(null);
    const [isLoaded, setIsLoaded] = useState(null);
    const [isUploading, setIsUploading] = useState(null);
    const [content, setContent] = useState({});
    const [uploader, setUploader] = useState(null);
    const [lastUpdated, setLastUpdated] = useState(null);
    const [lastUploaded, setLastUploaded] = useState(null);
    const [fileList, setFileList] = useState(null);
    const [isSaving, setSaving] = useState(false);

    const params = useParams();
    const navigate = useNavigate();

    useEffect(() => {
        if (!params.content_id) {
            setIsLoaded(true);
        } else {
            if (isLoaded === null)
                setIsLoaded(false);
            apiRequest(`/easyshare/apiContent/${params.content_id}`)
                .then(
                    (result) => {
                        setContent(result);
                        setFileList(result.files ?? []);
                        setLastUpdated(result.updated_at ?? null);
                        setIsLoaded(true);
                        loadUploaderForm();
                    },
                    (error) => {
                        setError(error);
                        setIsLoaded(true);
                    }
                )
        }
    }, [params, lastUploaded]);

    function loadUploaderForm() {
        fetch(`/easyshare/apiFiles/${params.content_id}`)
            .then(r => r.text())
            .then(html => {
                const parser = new DOMParser();
                const upload_form = parser.parseFromString(html, "text/html").getElementsByTagName('form')[0];
                setUploader(upload_form);
            });
    }

    function doUploadFile(event) {
        setIsUploading(true);
        const hiddenInput = uploader.querySelectorAll('[type="file"]')[0];
        event.target.name = hiddenInput.name;
        const clonedInput = event.target.cloneNode(true),
              originalParent = event.target.parentNode;
        const id_aux = event.target.id;
        event.target.id = null;
        clonedInput.id = id_aux;
        hiddenInput.parentNode.replaceChild(event.target, hiddenInput);
        originalParent.appendChild(clonedInput);
        const formData = new FormData(uploader);
        formData.append(uploader.querySelectorAll('button')[0].name, "");
        event.target.disabled = true;
        fetch(`/easyshare/${uploader.action.split('/easyshare/')[1]}`, {
            method: 'POST',
            body: formData,
            redirect: 'manual'
        }).catch(r => {return r}).then(response => {
            setIsUploading(false);
            loadUploaderForm();
            setLastUploaded(new Date());
            if (response.status != 0 && response.type != 'opaqueredirect')
                throw Error(response.status == 200 ? 'Unexpected error, have you selected a file?'
                    : response.statusText);
            return response;
        }).then(result => {
            myAlert("success", 'Success', "File uploaded successfully");
        }, error => {
            myAlert("error", 'Error', `Couldn't upload file: ${error ?? 'unexpected error'}`);
        })
    }
    function doSaveContent(event) {
        setSaving(true);
        event.preventDefault();
        apiRequest(params.content_id ? `/easyshare/apiContent/${params.content_id}` : `/easyshare/apiPosts/${params.repo_id}`,
            'POST', event.target)
            .then(
                (result) => {
                    if (!params.content_id) {
                        myAlert("success", "Content added!", "Your new post was created successfully");
                        navigate(`/contents/${result.id}/edit`, {replace: true});
                    }
                    setSaving(false);
                    setLastUpdated(new Date());
                },
                (error) => {
                    setSaving(false);
                    myAlert('error', 'Oops!', error ?? 'Error while saving content');
                    setLastUpdated(new Date());
                }
            )
    }
    
    return (
        !isLoaded ? <Spinner /> : (
            error ? (error ?? <TextMuted>Error while fetching the requested content</TextMuted>) : <>
                <form onSubmit={doSaveContent}>
                    {content.type=='submission' ? <TitleWithButtonBack>Edit submission</TitleWithButtonBack> : <>
                        <TitleWithButtonBack>{content.id ? 'Edit content' : 'Create content'}</TitleWithButtonBack>
                        <label htmlFor="title" className="form-label">Title</label>
                        <input id="title" type="text" name="title" defaultValue={content.title ?? ''} className="form-control mb-3" required/>
                        <label htmlFor="content" className="form-label">Content</label>
                    </>}
                            <textarea id="content" type="text" name="content" defaultValue={content.content ?? ''} className="form-control mb-0" rows="8" />{/* onChange={renderMarkdownPreview} */}
                        {/* </div>
                        <div className='col-md-6'>
                            <div id="md-preview" className='w-100 overflow-auto border rounded mt-4 p-2' />
                        </div>
                    </div> */}
                    <FormHelp><Icon name="markdown" me="2" />You can use <a href="https://commonmark.org/help/" target="_blank">Markdown</a> to add format</FormHelp>
                    {content.type=='post' ? <div className="form-group mb-3">
                        <label htmlFor='tag' className="form-label">Tag</label>
                        <select id="tag" className="form-select" name="tag" defaultValue={content.tag ?? ''}>
                            <option value="" disabled></option>
                            
                        </select>
                    </div> : ''}
                    <div className="text-center">
                        {params.content_id ? '' : <><div className='mt-3 form-check d-inline-block'>
                            <input id="assignment" name="is_assignment" value={true} type="checkbox" className="form-check-input" />
                            <label htmlFor='assignment' className='form-check-label'>Accept submissions</label>
                        </div><ClearFix /><p className='text-muted' style={{fontSize:'small'}}>You won't be able to change this setting later</p></>}
                        <button type="submit" className="btn btn-primary" disabled={isSaving}>
                            <Loader loading={isSaving}>{params.content_id ? 'Save changes' : 'Create post'}</Loader>
                        </button>
                        {params.content_id ? <p className="text-muted" style={{fontSize:'small'}}>
                            Last updated <TimeAgo timestamp={lastUpdated} />
                        </p> : ''}
                    </div>
                </form>
                {params.content_id ? <>
                    <h2>Attached files</h2>
                    <div key={lastUploaded}>
                        <label className='form-label d-block' htmlFor='fileInput'>Upload a new file</label>
                        <input type="file" onChange={doUploadFile} id='fileInput' className="form-control d-inline-block" style={{maxWidth: '300px'}} />
                        {isUploading ? <Spinner centered={false} small={true} /> : ''}
                    </div>
                </> : ''}
            </>
        )
    );
}

export function Search() {

    const params = useParams();
    const navigate = useNavigate();

    var TIME_THRESHOLD = 1;
    var lastCall = Date.now(), lastQuery = '';
    function doSearch(event) {
        event.preventDefault();
        let new_query = event.target.value ?? null;
        if (lastQuery == new_query)
            return;
        let now = Date.now();
        if (lastCall + TIME_THRESHOLD * 1000 > now) {
            setTimeout(() => doSearch(event), TIME_THRESHOLD * 1000);
            return;
        }
        lastCall = now;
        lastQuery = new_query;
        navigate(new_query ? `/search/${new_query}/1` : "/search", {replace: true})
    }

    return <>
        <h1>Search</h1>
        <p>Using this page, you can search among all the contents you have access to. Nice!</p>
        <input onChange={doSearch} placeholder="Start typing something..." defaultValue={params.query} className="form-control" />
        <Outlet key={`search${params.page??''}${params.query??''}`} />
    </>;
}

export function SearchResults() {

    const N_RESULTS = 6;
    const [error, setError] = useState(null);
    const [isLoaded, setIsLoaded] = useState(false);
    const [results, setResults] = useState([]);
    const params = useParams();
    let query = params.query ?? '',
        page = (parseInt(params.page) ?? 1) || 1;

    useEffect(() => {
        if ((params.query ?? '').length == 0) {
            setError("Results will appear here");
            setIsLoaded(true);
        }
        apiRequest(`/easyshare/apiContents/${query}/${N_RESULTS}/${N_RESULTS * (page - 1)}`)
            .then(
                (result) => {
                    setResults(result);
                    setIsLoaded(true);
                },
                (error) => {
                    setError(error);
                    setIsLoaded(true);
                }
            )
    }); //, [params.query, params.page])

    return (
        !isLoaded ? <Spinner /> : (
            error ? <TextMuted>{error ?? "Error while fetching the search results"}</TextMuted> : <>
                
                <div className="text-center">
                    <Link title="Previous page" to={`/search/${query}/${page-1}`} className={`btn btn-primary btn-rounded rounded-circle me-2${page > 1 ? '' : ' disabled'}`}>
                        <Icon name="chevron-left" /></Link>
                    <span className="mx-3">Page {page}</span>
                    <Link title="Next page" to={`/search/${query}/${page+1}`} className={`btn btn-primary btn-rounded rounded-circle me-2${results.length < N_RESULTS ? ' disabled' : ''}`}>
                        <Icon name="chevron-right" /></Link>
                </div>
            </>
        )
    );
}

export function MenuRepos() {

    const navigate = useNavigate();

    function joinRepo() {
        swalInput('Join a repository', 'Please enter your invite token below', 'text',
            token => {return apiRequest(`/easyshare/apiRepoJoin/${token}`, 'POST')
            .then(
                result => {
                    if (result.success)
                        myAlert('success', result.message)
                    if (result.repo_id)
                        navigate(`/repos/${result.repo_id}`);
                    else
                        myAlert('error', 'Oops!', result.message ?? "An unexpected error occurred. Please try again later.")
                },
                error => {
                    if (error.warning)
                        myAlert(error.status ?? 'error', 'Oops!', error.message ?? "An unexpected error occurred");
                    else
                        myAlert('error', 'Oops!', error ?? "Couldn't join the repository. Please check your token and try again.")
                    if (error.repo_id)
                        navigate(`/repos/${error.repo_id}`);
                }
            )}, 'Join')
    }
    function newRepo() {
        swalInput('Create a repository', 'Please enter the desired name below', 'text',
            new_name => {return apiRequest(`/easyshare/apiRepos/`, 'POST', null, {name: new_name})
            .then(
                result => {
                    if (result.id) {
                        navigate(`/repos/${result.id}/settings`);
                        myAlert("success", "Repository created!", "Your new repository was successfully created, you can now start sharing!")
                    } else {
                        myAlert("warning", "Couldn't create repository", "Unexpected error while creating the repository. Please try again later.")
                    }
                },
                error => {
                    myAlert('warning', 'You have reached your repository limit', "Please delete some or contact the administrator to increase the limit.");
                }
            )}, 'Create')
    }

    return <>
        <LeftRightDivs>
            <h1>My repositories</h1>
            <div className="btn-group">
                <button role="button" onClick={joinRepo} className="btn btn-primary rounded me-2"><Icon name="box-arrow-in-right" me="2" />Join repository</button>
                <button role="button" onClick={newRepo} className="btn btn-primary rounded"><Icon name="plus-lg" me="2" />Create new</button>
            </div>
        </LeftRightDivs>
        <p>In this page you can see all the repositories you own, manage and have access to.</p>
        <ul className="nav nav-tabs">
            <li className="nav-item">
                <NavLink className={navData => "nav-link" + (navData.isActive ? " active" : '')} to="/repos/shared">Shared with me</NavLink>
            </li>
            <li className="nav-item">
                <NavLink className={navData => "nav-link" + (navData.isActive ? " active" : '')} to="/repos/managed">Managed by me</NavLink>
            </li>
            <li className="nav-item">
                <NavLink className={navData => "nav-link" + (navData.isActive ? " active" : '')} to="/repos/owned">Owned by me</NavLink>
            </li>
        </ul>
        <Outlet />
    </>
}