This is a simple plugin to render a graph of the issues in a version that
have relationships to other tickets in the version.

Once the plugin is installed, an extra link will show up on the page that
shows all the tickets and progress for a version, named "View Issue
Relations Graph".  Just click that link and you'll get a graph.


# Installation requirements

## Redmine 1.2

This plugin was written for Redmine 1.2.0 (because that's the version we're
stuck on for now).  Patches to update it for newer versions (or reports that
it works as-is on newer versions) gratefully accepted.


## Graphviz

This plugin uses graphviz to render the graphs; you'll need to install it
and have it available in the PATH of the redmine app server before this
plugin will work at all.


# Acknowledgements

The initial structure of the controller's `graph` method was taken from code
provided by Jean-Phillipe Lang in http://www.redmine.org/issues/2448.  From
there, I bludgeoned it into a shape more suitable for my purposes, and put
it into a plugin.
