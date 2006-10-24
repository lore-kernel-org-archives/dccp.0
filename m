From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 07:48:47 +0000
Subject: Re: 2.6.19-rcX vs 2.6.20
Message-Id: <200610240848.47708@strip-the-willow>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_fVcPFwOshYleTDd"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--Boundary-00=_fVcPFwOshYleTDd
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

It seems that I am not the only one having headaches about which patches
are applied and which not. I spent a major part yesterday trying to get
the set of patches consistent with regard to Dave's/Arnaldo's latest tree.

What I have been doing over time is collecting all patches that were posted on this
list and have not made it upstream into a consistent, stacked set of patches.

With my own work this adds up to currently 17 patches, including:
	* 3 patches from Andrea which have also not been merged
	* 1 patch (typo) by Ian which has not been merged
	* patches from me with annotations that Arnaldo made incorporated
	* a few bug fixes (see also earlier posting)
	* general updates (such as the one Ian pointed out, but also the
          second part of the oops patch to reduce the number of forward decls)

Every day, after pulling, I have to reconstruct the whole stacked batch of patches
by applying them one after the other again. Even the script which does this is tedious.
Now I see the headaches it costs Arnaldo as well and hence:

  ==> Is there any way of using a separate DCCP repository for the mere purpose of
      keeping accepted and discussed patches in a consistent state?

It is little point if everyone keeps a separate stack of patches. On the other hand, it
is frustrating work having to chase after old and partially applied patches, battle with
rebased trees, merged close windows etc. 

With regard to 2.6.19-rX vs 2.6.20 I think that it is better not to submit more patches
not (only) because David said so, but with regard to `postponing headaches': all non-2.6.19-rX
patches have later again to be rebased/changed. Yesterday, this killed two of my repositories
and I had to change each manually from scratch again.


Arnaldo, what do you think is best ? I think it would be ideal if there was a consistent
tree, that would save a lot of work. 

What I could contribute to make this easier is to keep track of changes and merging (i.e.
the grunt work) - I am pulling the latest netdev tree daily anyway. Would this help? I am
not insinuating bypassing the revision process, but I am getting tired of rebasing. 

Well I hope it won't stay like this forever ...



PS: Ian, for a laugh I attach a script which I have been using a lot, it basically
answers your question `is this upstream or not' - in colour :)

--Boundary-00=_fVcPFwOshYleTDd
Content-Type: application/x-shellscript;
  name="is_patched_already.sh"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="is_patched_already.sh"

#!/bin/sh
#
# usage: $0 <patch name>
#
# This script tries to answer whether a patch has already been applied or not.
#
function log() {
  echo -e "\033[1;34;7m$@\033[m";
}

function ok() {
  echo -e "\033[30;42m$@\033[m"; >&2
}

function not_ok() {
  echo -e "\033[1;37;41m$@\033[m"; >&2

}
function die() {
  echo -e "$@"
  exit 1
}

# SCRIPT PROPER
test $# -ge 1  || die "Usage: ${0##*/} patch-name(s)"
test -d ./.git || die "${0##*/}: This script requires a .git repository"
unset next

for patch
do
  test -f $patch || die "\033[31mnot a file: $patch\033[m"
  log "Trying  ${patch} ..."
  if git-apply --check < "$patch"
  then 
    ok "${patch##*/} has not been applied on this code and applies cleanly"
    continue
  fi
  echo -e "\033[1mtrying REVERSE -R ...\033[m"
  if git-apply -R --check < "$patch"
  then
    not_ok "${patch##*/} has been applied"
  else
    not_ok "${patch##*/} does not patch cleanly on this code"
  fi
done

--Boundary-00=_fVcPFwOshYleTDd--
