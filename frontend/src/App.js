import logo from './logo.svg'
import './App.css'
import {
	BrowserRouter as Router,
	Routes,
	Route,
	Link
} from "react-router-dom"
import {
	useState,
	useEffect,
	createRef,
	useRef
} from 'react'
import {
	readableDateDiff,
	myAlert,
	apiRequest,
	firstUpper
} from './util.js'
import Swal from 'sweetalert2'
import {
	Spinner,
	TextMuted,
	ClearFix,
	Loader,
	TitleWithButtonBack,
	Redirect
} from './components/basicComponents.js'
import {
	BasicLayout,
	MainLayout
} from './components/layoutComponents.js'
import {
	Home,
	Poll,
	EditPoll
} from './components/pageComponents.js'

function App() {
        
    const [userData, setUserData] = useState(null);
    const [error, setError] = useState(null);
    const [isLoaded, setIsLoaded] = useState(false);
    const [isLoggingIn, setLoggingIn] = useState(false);
    const [darkMode, setDarkMode] = useState((localStorage.getItem('darkMode') ?? 'false') == 'true');
    const loginForm = useRef(),
          registerForm = useRef();

    useEffect(() => {
        doLogin()
    }, [])

    function doLogin(password) {
		return new Promise((resolve, reject) => {
			setLoggingIn(true)
			apiRequest("login", password ? 'POST' : 'GET', password ? {
				password: password
			} : null)
				.then(
					(result) => {
						resolve()
						if (result.session_id) {
							setUserData({
								is_admin: result.is_admin ?? false,
								session_id: result.session_id ?? null
							})
						}
						setIsLoaded(true)
						setLoggingIn(false)
					},
					(error) => {
						reject()
						// setIsLoaded(true)
						// setError(error)
						setUserData({})
						/// setLoggingIn(false)
					}
				)
		})
    }
    function doLogout() {
        setIsLoaded(false);
        apiRequest("logout")
            .then(
                (result) => {
                    setUserData(null)
                    setIsLoaded(true)
                },
                (error) => {
                    setError(error)
                    setUserData(null)
                    setIsLoaded(true)
                }
            )
    }
    function clearFields(event) {
        loginForm.current?.reset()
    }
    function toggleDarkMode() {
        setDarkMode(!darkMode)
        localStorage.setItem('darkMode', !darkMode ? 'true' : 'false')
    }

    return <div className={`min-vh-100 ${darkMode ? 'dark-mode' : 'dark-mode-disabled'}`}><Router>
        {!isLoaded ? <BasicLayout><Spinner /></BasicLayout> : 
            (error ? <BasicLayout title="Error" icon="exclamation-triangle-fill" subtitle="Couldn't authenticate">{error ?? ""}</BasicLayout> : 
                // Authentication
                !(userData ?? false) ? <Routes>
                    <Route index element={<BasicLayout title="Login" icon="lock-fill" subtitle="To access this page, authenticate first">    
                        <form className="text-center" onSubmit={doLogin} ref={loginForm}>
                            <input name="email" type="email" placeholder="Email" autoFocus className="form-control mb-2 d-inline-block" style={{"maxWidth": "300px"}} required/>
                            <ClearFix />
                            <input name="pass" type="password" placeholder="Password" className="form-control mb-3 d-inline-block" style={{"maxWidth": "300px"}} required/>
                            <ClearFix />
                            <button className="btn btn-primary button" type="submit">
                                <Loader loading={isLoggingIn}>Let me in!</Loader>
                            </button>
                            <ClearFix />
                            <Link to="/register" style={{"fontSize": "smaller"}}>Create new account</Link>
                        </form>
                    </BasicLayout>} />
                </Routes> :
                // Actual web application
                <Routes>
                    <Route path="/" element={<MainLayout darkMode={darkMode} toggleDarkMode={toggleDarkMode} admin={userData.is_admin} doLogin={doLogin} doLogout={doLogout} />}>
                        <Route path="/" element={<Home isAdmin={userData.is_admin} />} />
						<Route path="/polls" element={<Home isAdmin={userData.is_admin} />} />
                        <Route path="/polls/:poll_id" element={<Poll isAdmin={userData.is_admin} />} />
                        <Route path="/polls/:poll_id/edit" element={<EditPoll isAdmin={userData.is_admin} />} />
                    </Route>
                    <Route path="*" element={<BasicLayout title="Page not found" subtitle="The page you are looking doesn't exist" icon="exclamation-triangle-fill" />} />
                </Routes>
            )
        }
    </Router></div>;
}

export default App;
