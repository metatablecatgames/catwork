When I created Tabby 2 years ago, I wanted to provide an asynchronous execution model that ModuleScripts can depend on.

Catwork was the final resolution of this, but with Services caked ontop of it, however, with the new type solver, and how Luau has evolved as a language, everything Catwork can do can be done so much easier with just an Action. (Funilly enough, original Catwork used an action in its Dispatcher).

Recently, I've discovered that a lot of Catwork code is actually just boilerplate caked ontop of what is basically an extension of the Catlibs (remember that old thing?), Action class.

The entire Object class can be abstracted cleaner by just returning an Action, awaiting upon it, and then capturing the response for future calls.

For this reason, I dont see the usecase in Catwork anymore, when a well-tuned Action can substantiate it entirely.

---

Regarding runtime execution, Catwork never formally defined how to accomplish this, though I internally used collection service tags that would then load the module. This has nothing to do with Catwork.
