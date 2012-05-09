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

$(eval $(call gb_CustomTarget_CustomTarget,translations/translate,new_style))

TRTR := $(call gb_CustomTarget_get_workdir,translations/translate)

$(call gb_CustomTarget_get_target,translations/translate) : $(TRTR)/merge.done

ifeq ($(WITH_LANG),ALL)
tr_langs := $(shell cd $(SRCDIR)/translations/source && ls -1)
else
tr_langs := $(filter-out en-US,$(WITH_LANG))
endif

#TODO: remove localization_present.mk when translations are in tail_build
$(TRTR)/merge.done : $(foreach lang,$(tr_langs),$(TRTR)/sdf-l10n/$(lang).sdf) \
		$(TRTR)/sdf-l10n/qtz.sdf
	$(call gb_Output_announce,$(subst $(WORKDIR)/,,$@),$(true),MRG,2)
	$(call gb_Helper_abbreviate_dirs, \
		rm -rf $(TRTR)/sdf && mkdir $(TRTR)/sdf && \
		RESPONSEFILE=$(call var2file,$(shell $(gb_MKTEMP)),100,$^) && \
		perl $(OUTDIR_FOR_BUILD)/bin/fast_merge.pl -sdf_files $${RESPONSEFILE} \
			-merge_dir $(TRTR)/sdf \
			$(if $(findstring s,$(MAKEFLAGS)),> /dev/null) && \
		rm -f $${RESPONSEFILE} && \
		cp -f $(SRCDIR)/translations/localization_present.mk \
			$(WORKDIR)/CustomTarget/translations/localization_present.mk && \
		touch $@)

define lang_rule
$(TRTR)/sdf-l10n/$(1).sdf : $(TRTR)/sdf-template/en-US.sdf $(OUTDIR_FOR_BUILD)/bin/po2lo \
		$$(shell find $(SRCDIR)/translations/source/$(1) -name "*\.po") | $(TRTR)/sdf-l10n/.dir
	$$(call gb_Output_announce,$$(subst $(WORKDIR)/,,$$@),$(true),SDF,1)
	$$(call gb_Helper_abbreviate_dirs, \
		$(gb_PYTHON) $(OUTDIR_FOR_BUILD)/bin/po2lo --skipsource -i \
			source/$(1) -t $$< -o $$@ -l $(1))

endef

$(foreach lang,$(tr_langs),$(eval $(call lang_rule,$(lang))))

$(TRTR)/sdf-l10n/qtz.sdf : $(TRTR)/sdf-template/en-US.sdf \
		$(OUTDIR_FOR_BUILD)/bin/keyidGen.pl | $(TRTR)/sdf-l10n/.dir
	$(call gb_Output_announce,$(subst $(WORKDIR)/,,$@),$(true),SDF,1)
	$(call gb_Helper_abbreviate_dirs, \
		perl $(OUTDIR_FOR_BUILD)/bin/keyidGen.pl $< $@ \
			$(if $(findstring s,$(MAKEFLAGS)),> /dev/null))

$(TRTR)/sdf-template/en-US.sdf : $(OUTDIR_FOR_BUILD)/bin/propex \
		$(foreach exec,cfgex helpex localize transex3 ulfex xrmex, \
			$(call gb_Executable_get_target_for_build,$(exec)))
	$(call gb_Output_announce,$(subst $(WORKDIR)/,,$@),$(true),LOC,1)
	$(call gb_Helper_abbreviate_dirs, \
		mkdir -p $(dir $@) && $(call gb_Helper_execute,localize) $(SRCDIR) $@)

# vim: set noet sw=4 ts=4:
