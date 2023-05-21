import {
    useState,
    useEffect
} from 'react';
import {
    Outlet,
    useParams,
    NavLink
} from "react-router-dom";
import {
    myAlert,
    apiRequest,
    parseMarkdown,
    plural
} from '../util.js'
import {
    Spinner,
    CardAction,
    CardCollection,
    Icon,
    TitleWithButtonBack,
    TimeAgo,
    Redirect
} from './basicComponents.js'
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from "chart.js";
import { Doughnut } from "react-chartjs-2";

export function Home(props) {
    return <>
        <h1 className='text-center'>Welcome to PollApp</h1>
        <p className="h5 fw-normal text-center">This is what democracy looks like!</p>
        <hr className="mt-4 mb-3" />
        {/*<h2 className="h3">Here are some polls for you</h2>*/}
        <PollList />
    </>
}

export function PollList(props) {

    const [error, setError] = useState(null)
    const [isLoaded, setIsLoaded] = useState(false)
    const [items, setItems] = useState([])

    useEffect(() => {
        apiRequest('polls/')
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
                    descr: <div className='m-2 d-flex flex-column'>
                        <div><Icon name="bar-chart-fill" me="2" />{i.options_count} option{plural(i.options_count)}</div>{/*grid-fill*/}
                        <div><Icon name="people-fill" me="2" />{i.answers_count} answer{plural(i.answers_count)}</div>
                        <div><Icon name="clock-fill" me="2" />Created <TimeAgo timestamp={i.timestamp} /></div>
                    </div>,
                    actions: <CardAction text="Vote" icon="send-fill" to={`/polls/${i.id}`} />
                }))} empty_msg={props.empty_msg || "No polls have been created (yet)"} />
        )
    )
}

export function PollMenu(props) {
    const params = useParams()
    function getId() {
        return params.poll_id
    }
    const [poll, setPoll] = useState({
        title: "Loading...",
        answers_count: 0,
        timestamp: 0
    })
    useEffect(() => {
        apiRequest(`poll/${params.poll_id}`)
            .then(
                (result) => {
                    setPoll(result)
                },
                (error) => {
                    setPoll({
                        title: "Error",
                        answers_count: 0,
                        timestamp: 0
                    })
                }
            )
    }, [params.poll_id])
    return <>
        <TitleWithButtonBack text="All polls" mb="1" href="/">{poll.title}</TitleWithButtonBack>
        <p className="mb-3 p-0 text-muted">{poll.answers_count} answer{plural(poll.answers_count)} so far | Posted <TimeAgo timestamp={poll.timestamp} /></p>
        <ul className="nav nav-tabs">
            <li className="nav-item">
                <NavLink replace className={navData => "nav-link" + (navData.isActive ? " active" : '')} to={`/polls/${getId()}`} end>Vote</NavLink>
            </li>
            <li className="nav-item">
                <NavLink replace className={navData => "nav-link" + (navData.isActive ? " active" : '')} to={`/polls/${getId()}/results`}>Results</NavLink>
            </li>
        </ul>
        <Outlet />
    </>
}

export function PollResults(props) {

    ChartJS.register(ArcElement, Tooltip, Legend)

    const [error, setError] = useState(null)
    const [isLoaded, setIsLoaded] = useState(false)
    const [poll, setPoll] = useState([])
    const params = useParams()

    useEffect(() => {
        setIsLoaded(false);
        apiRequest(`poll/${params.poll_id}`)
            .then(
                (result) => {
                    setPoll(result)
                    setIsLoaded(true)
                },
                (error) => {
                    setError(error)
                    setIsLoaded(true)
                }
            )
    }, [params])

    return (
        !isLoaded ? <Spinner /> : (
            error ? <p>{error ?? "Error while fetching the requested poll"}</p> : <>
                {parseMarkdown(poll.content ?? '')}
                <div className='m-4 w-100'>
                    <div className='m-auto' style={{ minHeight: '300px', maxHeight: '75vh', maxWidth: '500px' }}>
                        <Doughnut data={{
                            labels: poll.options.map(o => o.text),
                            datasets: [{
                                label: 'Votes',
                                data: poll.options.map(o => o.answers_count),
                                backgroundColor: ["#FF0000", "#00FF00", "#0000FF", "#33AEEF", "#FFA500", "#FF00FF", "#00FFFF", "#000000", "#FFC0CB", "#808080", "#800000", "#008000", "#000080", "#808000", "#800080", "#008080", "#C0C0C0", "#FFFFFF", "#FFFF00", "#00FF00", "#00FFFF", "#0000FF", "#FF00FF", "#FF0000", "#000000", "#808080", "#800000", "#008000", "#000080", "#808000", "#800080", "#008080", "#C0C0C0", "#FFFFFF", "#FFFF00", "#00FF00", "#00FFFF", "#0000FF", "#FF00FF", "#FF0000", "#000000", "#808080", "#800000", "#008000", "#000080", "#808000", "#800080", "#008080", "#C0C0C0", "#FFFFFF", "#FFFF00", "#00FF00", "#00FFFF", "#0000FF", "#FF00FF", "#FF0000", "#000000", "#808080", "#800000", "#008000", "#000080", "#808000", "#800080", "#008080", "#C0C0C0", "#FFFFFF", "#FFFF00", "#00FF00", "#00FFFF", "#0000FF", "#FF00FF", "#FF0000", "#000000", "#808080", "#800000", "#008000", "#000080", "#808000", "#800080", "#008080", "#C0C0C0", "#FFFFFF", "#FFFF00", "#00FF00", "#00FFFF", "#0000FF", "#FF00FF", "#FF0000"],
                            }]
                        }} options={{
                            plugins: {
                                legend: {
                                    display: true,
                                    position: 'right',
                                    align: 'center'
                                }
                            },
                            responsive: true,
                            maintainAspectRatio: false
                        }} />
                    </div>
                </div>
            </>
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
        if (selectedOption !== null) {
            apiRequest(`vote/${selectedOption}`, 'POST')
                .then(
                    (result) => {
                        setUserHasAnswered(true)
                    },
                    (error) => {
                        myAlert("error", "Couldn't vote", error)
                        // setError(error)
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
                <div className='d-flex align-items-center justify-content-center flex-column'>
                    <div className="m-4">
                        {poll.options.length === 0 ? <p>No options have been added yet</p> :
                            poll.options.map(o => <div className="form-check" key={o.id}>
                                <input className="form-check-input" type="radio" name="flexRadioDefault" id={`radio-${o.id}`} disabled={userHasAnswered} checked={selectedOption === o.id} onChange={(e) => { if (e.target.checked) setSelectedOption(o.id) }} />
                                <label className="form-check-label" htmlFor={`radio-${o.id}`}>{o.text}</label>
                            </div>)
                        }
                    </div>
                    <button type="button" className={`btn btn-primary btn-lg${userHasAnswered || selectedOption === null ? " disabled" : ""}`} onClick={doVote}>
                        <Icon name="send-fill" me="2" />Submit vote
                    </button>
                </div>
            </>
        )
    )
}
