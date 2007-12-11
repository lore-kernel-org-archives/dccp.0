From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 11 Dec 2007 09:42:38 +0000
Subject: Re: [PATCH 8/8] [PATCH v2] [CCID3]: Interface CCID3 code with newer Loss Intervals Database
Message-Id: <20071211094238.GA9926@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| When interfacing we must make sure that ccid3 tfrc_lh_slab is created
| and then tfrc_li_cachep is not needed. I'm doing this while keeping
| the structure of the patches, i.e. one introducing, the other removing.
| But we need to create tfrc_lh_slab if we want the tree to be bisectable.
| 
| I'm doing this and keeping your Signed-off-line, please holler if you
| disagree for some reason.
If you are just shifting and reordering then that is fine with me. But
it seems you mean a different patch since in this one there is no slab
initialisation. 
The loss history and the RX/TX packet history slabs are all created in
tfrc.c using the three different __init routines of the dccp_tfrc_lib.
