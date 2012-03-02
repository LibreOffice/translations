# -*- Mode: makefile-gmake; tab-width: 4; indent-tabs-mode: t -*-
#
# Version: MPL 1.1 / GPLv3+ / LGPLv3+
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License or as specified alternatively below. You may obtain a copy of
# the License at http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# Major Contributor(s):
# Copyright (C) 2012 Matúš Kukan <matus.kukan@gmail.com> (initial developer)
#
# All Rights Reserved.
#
# For minor contributions see the git repository.
#
# Alternatively, the contents of this file may be used under the terms of
# either the GNU General Public License Version 3 or later (the "GPLv3+"), or
# the GNU Lesser General Public License Version 3 or later (the "LGPLv3+"),
# in which case the provisions of the GPLv3+ or the LGPLv3+ are applicable
# instead of those above.

gb_PARTIALBUILD:=T
include $(GBUILDDIR)/gbuild_simple.mk

all: merge.done

all_languages := $(shell cd $(SRCDIR)/translations/source && ls -1)
ifeq ($(WITH_LANG),ALL)
my_languages := $(all_languages)
else
my_languages := $(filter-out en-US,$(WITH_LANG))
endif

#TODO: remove localization_present.mk when translations are in tail_build
merge.done: $(foreach lang,$(my_languages),sdf-l10n/$(lang).sdf) sdf-l10n/qtz.sdf
	$(call gb_Helper_abbreviate_dirs_native, \
		rm -rf sdf && mkdir sdf && \
		perl $(OUTDIR_FOR_BUILD)/bin/fast_merge.pl -sdf_files \
			$(call var2file,$(shell $(gb_MKTEMP)),100,$^) -merge_dir sdf && \
		cp -f $(SRCDIR)/translations/localization_present.mk \
		$(WORKDIR)/CustomTarget/translations/localization_present.mk && \
		touch $@)

define lang_rule
sdf-l10n/$(1).sdf: sdf-template/en-US.sdf $(OUTDIR_FOR_BUILD)/bin/po2lo \
		$(shell find $(SRCDIR)/translations/source/$(1) -name "*\.po") | sdf-l10n
ifeq ($(OS_FOR_BUILD),WNT)
	$(call gb_Helper_abbreviate_dirs_native, \
		$(gb_PYTHON) $(shell cygpath -m $(OUTDIR_FOR_BUILD))/bin/po2lo --skipsource -i \
			$(shell cygpath -m $(SRCDIR)/translations/source/$(1)) -t $$< -o $$@ -l $(1))
        $(echo $(gb_PYTHON))
else
	$(call gb_Helper_abbreviate_dirs_native, \
		$(gb_PYTHON) $(OUTDIR_FOR_BUILD)/bin/po2lo --skipsource -i \
			$(SRCDIR)/translations/source/$(1) -t $$< -o $$@ -l $(1))
endif
endef

$(foreach lang,$(my_languages),$(eval $(call lang_rule,$(lang))))

sdf-l10n/qtz.sdf: sdf-template/en-US.sdf $(OUTDIR_FOR_BUILD)/bin/keyidGen.pl | sdf-l10n
	$(call gb_Helper_abbreviate_dirs_native, \
		perl $(OUTDIR_FOR_BUILD)/bin/keyidGen.pl $< $@)

sdf-l10n:
	mkdir $@

sdf-template/en-US.sdf: \
		$(foreach file,cfgex helpex localize propex transex3 ulfex xrmex, \
			$(OUTDIR_FOR_BUILD)/bin/$(file))
	$(call gb_Helper_abbreviate_dirs_native, \
		mkdir -p $(dir $@) && $(call gb_Helper_execute,localize) $(SRCDIR) $@)

.DEFAULT_GOAL := all
# vim: set noet sw=4 ts=4:
