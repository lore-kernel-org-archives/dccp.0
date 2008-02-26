From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 26 Feb 2008 13:48:02 +0000
Subject: Re: [PATCH 2/2] [ACKVEC]: Schedule Sync as out-of-band mechanism
Message-Id: <20080226134802.GA12987@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1203933122-27140-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1203933122-27140-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| code like the wifi driver that just work in 2.6.21.
| 
If it is of any help, I still keep the per-release patch sets on
 http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/

Will probably not help much with back-porting, but can be used (with
patch-utils / interdiff) to get a quick overview of what is happening.

I normally also send an inventory of all patches to Arnaldo, maybe
should post this also to the list.

| By the way, I had some issues to solve and I have just finish the
| modifications in the dccp plugin for gstreamer today. I will just now
| write the release notes, submit the new .tar.gz2 to the
| garage.maemo.org (as the previous version) and I will let you know the
| link to download it.
Looking forward to testing the new version. Will also finish the two
mpg123 patches and a little "piper" application. This worked together
with the gstreamer plugin. 

Haven't tested gstreamer with streaming from/to VLC yet.

I suppose the link will again be?:-
	https://garage.maemo.org/frs/?group_id)7
