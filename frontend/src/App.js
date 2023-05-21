import './App.css'
import {
	BrowserRouter as Router,
	Routes,
	Route
} from "react-router-dom"
import React, {
	useState,
	useEffect
} from 'react'
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
	PollResults,
	PollMenu
} from './components/pageComponents.js'

function App() {

	const [userData] = useState(null)
	const [error] = useState(null)
	const [isLoaded, setIsLoaded] = useState(false)
	const [darkMode, setDarkMode] = useState((localStorage.getItem('darkMode') ?? 'false') === 'true')

	useEffect(() => {
		setIsLoaded(true)
	}, [userData])

	function toggleDarkMode() {
		setDarkMode(!darkMode)
		localStorage.setItem('darkMode', !darkMode ? 'true' : 'false')
	}

	return <div className={`min-vh-100 ${darkMode ? 'dark-mode' : 'dark-mode-disabled'}`}><Router>
		{!isLoaded ? <BasicLayout><Spinner /></BasicLayout> :
			(error ? <BasicLayout title="Error" icon="exclamation-triangle-fill" subtitle="Couldn't authenticate">{error ?? ""}</BasicLayout> :
				<Routes>
					<Route path="/" element={<MainLayout darkMode={darkMode} toggleDarkMode={toggleDarkMode} />}>
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
