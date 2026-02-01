/**
 * Entry point for the bundled server. PureScript compiles to a module that
 * exports `main` but does not run it; Node exits immediately unless we call it.
 */
import { main } from "./output/Main/index.js";
main();
