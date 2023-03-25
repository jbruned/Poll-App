import {
    Link,
    Outlet,
    useNavigate
} from "react-router-dom";
import Swal from "sweetalert2";
import { apiRequest, myAlert, swalInput } from "../util";
import { Icon } from "./basicComponents";

export function BasicLayout(props) {
    return (
        <div className="bg-light w-100" style={{ height: '100vh' }}>
            <main className="container position-absolute top-50 start-50 translate-middle text-center p-2 pb-5" style={{ maxWidth: '444px' }}>
                {props.title && <h1>
                    {props.icon && <i className={`bi bi-${props.icon} me-3`}></i>}
                    {props.title}
                </h1>}
                {props.subtitle && <p className="lead">{props.subtitle}</p>}
                {props.children}
            </main>
        </div>
    )
}

export function MainLayout(props) {

    const navigate = useNavigate()

    function createPoll() {
        swalInput('Create poll', 'Enter poll title', 'text', 'Create', title => {
            apiRequest('polls', 'POST', {
                title: title
            }).then(res => {
                if (res.id)
                    navigate(`/poll/${res.id}`)
                else
                    myAlert('Something went wrong', 'An error occurred while creating the poll', 'error')
            })
        })
    }

    function adminLogin() {
        swalInput('Admin login', 'Enter admin password', 'password', 'Login', props.doLogin)
            .then(() => { Swal.close() })
            .catch(() => { Swal.setValidationMessage('Incorrect password') })
    }

    return (
        <>
            <nav className="navbar navbar-expand-lg navbar-dark bg-primary">
                <div className="container">
                    <Link to="/" className="navbar-brand">PollApp</Link>
                    <button type="button" data-bs-toggle="collapse" data-bs-target="#navbar-content" aria-controls="navbar-content" aria-expanded="false" aria-label="Toggle menu" className="navbar-toggler">
                        <span className="navbar-toggler-icon"></span>
                    </button>
                    <div id="navbar-content" className="collapse navbar-collapse">
                        <ul className="navbar-nav ms-auto mb-2 mb-lg-0">
                            <li className="nav-item">
                                <Link to="/" className="nav-link text-white">Home</Link>
                            </li>
                            {/*<li className="nav-item">
                                    <Link to="/edit" className="nav-link text-white">Create poll</Link>
                                </li>
                                {(props.admin ?? false) ? (
                                    <li className="nav-item dropdown">
                                        <a href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false" className="nav-link dropdown-toggle text-light">Admin</a>
                                        <ul aria-labelledby="admin-dropdown" className="dropdown-menu dropdown-menu-end">
                                            <li>
                                                <Link to="/admin/tokens" className="dropdown-item">Change password</Link>
                                            </li>
                                            <li>
                                                <Link to="/admin/stats" className="dropdown-item">Logout</Link>
                                            </li>
                                        </ul>
                                    </li>
                                ) : (
                                    <li className="nav-item">
                                        <a href="#" className="nav-link text-white" onClick={adminLogin}>Login</a>
                                    </li>
                                )*/}
                            <li>
                                {/* <button role="button" onClick={props.toggleDarkMode} className="dropdown-item">Toggle dark mode</button> */}
                                <div className="my-switch">
                                    <input id="my-switch" className="check-toggle check-toggle-round-flat" type="checkbox" checked={props.darkMode} onChange={props.toggleDarkMode} />
                                    <label htmlFor="my-switch" />
                                    <span className="on"><Icon name="sun-fill" /></span>
                                    <span className="off"><Icon name="moon-fill" /></span>
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
            <main className="container my-5">
                <Outlet />
            </main>
        </>
    )
}