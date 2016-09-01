DESTDIR		=

TARGETDIR	= $(DESTDIR)/usr/bin
INSTALL		= install -m 755 -p -D -t

MANPAGE		= xdg-bash-functions.1.gz
MANDIR		= $(DESTDIR)/usr/share/man/man1
MANINSTALL	= install -m 644 -p -D -t

start:

install:
	$(INSTALL) "$(TARGETDIR)" mime-functions icon-functions
	$(MANINSTALL) "$(MANDIR)" "$(MANPAGE)"

uninstall:
	$(RM) "$(TARGETDIR)/mime-functions" "$(TARGETDIR)/icon-functions"
	$(RM) "$(MANDIR)/$(MANPAGE)"
