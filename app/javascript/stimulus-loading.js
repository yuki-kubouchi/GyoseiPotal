// This file is required for Stimulus's automatic loading feature
// It will be automatically required by the Stimulus framework

import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
