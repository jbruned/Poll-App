import './App.css'
import {
	BrowserRouter as Router,
	Routes,
	Route,
    useParams
} from "react-router-dom"
import React, {
	useState,
	useEffect
} from 'react'
import {
	apiRequest
} from './util.js'
import {
	Spinner
} from './components/basicComponents.js'
import {
	BasicLayout,
	MainLayout
} from './components/layoutComponents.js'
import {
	Home,
	Poll,
	EditPoll,
    PollResults,
    PollMenu
} from './components/pageComponents.js'

function App() {
        
    const [userData, setUserData] = useState(null)
    const [error, setError] = useState(null)
    const [isLoaded, setIsLoaded] = useState(false)
    const [darkMode, setDarkMode] = useState((localStorage.getItem('darkMode') ?? 'false') == 'true')

    useEffect(() => {
        doLogin()
    }, [])

    function doLogin(password) {
		return new Promise((resolve, reject) => {
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
					},
					(error) => {
						reject()
						setIsLoaded(true)
						// setError(error)
						setUserData({})
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
    function toggleDarkMode() {
        setDarkMode(!darkMode)
        localStorage.setItem('darkMode', !darkMode ? 'true' : 'false')
    }

    return <div className={`min-vh-100 ${darkMode ? 'dark-mode' : 'dark-mode-disabled'}`}><Router>
        {!isLoaded ? <BasicLayout><Spinner /></BasicLayout> : 
            (error ? <BasicLayout title="Error" icon="exclamation-triangle-fill" subtitle="Couldn't authenticate">{error ?? ""}</BasicLayout> : 
                <Routes>
                    <Route path="/" element={<MainLayout darkMode={darkMode} toggleDarkMode={toggleDarkMode} />}>{/*admin={...} doLogin={doLogin} doLogout={doLogout}*/}
                        <Route path="/" element={<Home />} />
						<Route path="polls" element={<Home />} />
                        <Route path="polls/:poll_id/" element={<PollMenu />}>
                            <Route index element={<Poll />} />
                            <Route path="/polls/:poll_id/results" element={<PollResults />} />
                        </Route>
                    </Route>
                    <Route path="*" element={<BasicLayout title="Page not found" subtitle="The page you are looking doesn't exist" icon="exclamation-triangle-fill" />} />
                </Routes>
            )
        }
    </Router></div>
}

export default App
