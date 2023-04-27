import {
    Link,
    Outlet
} from "react-router-dom";
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
                            <li>
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