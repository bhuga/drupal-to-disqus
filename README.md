# Migrate from Drupal comments to Disqus

This is a simple script to migrate a basic use case Drupal 6 site to Disqus.
It talks to the database directly, rather than mess around with Drupal APIs,
which means complicated use cases are probably not well represented.

## Requirements

You'll need the Sequel gem.  The Disqus gem is also required, but has a bug
(fixed and submitted), so a copy is distributed here.  You may also need the
appropriate mysql or postgres adapters; If you get an error, Sequel will tell
you what to do.  See <http://sequel.rubyforge.org/documentation.html> for more
information.

For most working Ruby installations, this is all need to do:

    $ sudo gem install sequel --no-rdoc --no-ri

To use:
1. Copy db.yml.example to db.yml and edit appropriately.
1. Run the `import_comments.rb` script
1. Optionally run the `disable_old_comments.rb` script to set the display of
comments on all nodes to disabled.

## Issues

Drupal comments don't map directly to Disqus.  The following issues apply:

1. You will lose authorship.  Disqus will track names and email addresses, but
consider all comments anonymous.
1. Disqus does not support comment subjects.
1. Disqus supports only very basic HTML input filters.  If your users are using
markdown or any other input filter beyond the most basic, that formatting will
be lost.

## Author

Ben Lavender <http://bhuga.net>

## "License"
This software is free software released into the public domain.  See the UNLICENSE
file distributed with this software.

The Disqus module is redistributed here, which is released under the MIT
license.  See the `disqus/` folder for more information.


