# Makefile fuer Neko::HeatMap

# Fuer make test
export PERLLIB=../lib

BASEDIR=/tmp/HeatMap
STAGINGBASEDIR=/tmp/HeatMap-staging

LIBDIR=lib

DEVEL_CONF=devel
STAGING_CONF=staging
LIFE_CONF=life

all:

install: all
	# install -d -m 775 -o neko -g Gruppe $(LIBDIR)
	install -d -m 775 $(BASEDIR)/$(LIBDIR)
	install -d -m 775 $(BASEDIR)/$(LIBDIR)/Neko
	install -d -m 775 $(BASEDIR)/t
	install -d -m 775 $(BASEDIR)/bin

	install -b -C -m 755 -o neko lib/Neko/HeatMap.pm $(BASEDIR)/(LIBDIR)/Neko/

        ln -sf  $(BASEDIR)/t/HeatMap_$(CONFIG).conf $(BASEDIR)/t/HeatMap.conf

test:
        cd $(BASEDIR)/t/; echo ${PERLLIB}; echo `pwd`
        # cd $(BASEDIR)/t/; ./uses.t
        cd $(BASEDIR)/t/; ./testme_all.t

install-staging:
        make BASEDIR=$(STAGINGBASEDIR) install
        cp html/css/staging.css /home/neko/staging/html/css/area.css
        ln -sf  /home/neko/staging/lib/HeatMao_staging.conf.pm /home/neko/staging/lib/HeatMappConf.pm
