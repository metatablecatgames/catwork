# Future of Catwork.

You may have noticed I archived Catwork in September, this was done due to issues with Luau
typing. I've decided to unarchive the project and work on 0.6.0! The goal of 0.6.0 is going
to get Catwork's exports to actually work with the new solver, despite how painful that will
probably be.

If you're one of the 5 people who actually use this thing, enjoy having the knowledge that
I'm maintaining it again.

If you're still using one of the 0.5.0 betas, please ensure you're using the **old** typing
engine, the new one refuses to work under Catwork.

Another thing that I'm going to change in CW6 is how Await/HandleAsync pops off the top, instead of returning the table, it will now return an optional export table, as well as a new dispatcher that works under deferred threads.
