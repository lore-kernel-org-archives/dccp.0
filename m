From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 13 Oct 2009 17:18:47 +0000
Subject: [PATCHv2 1/4] First Patch on TFRC-SP. Copy base files from TFRC
Message-Id: <4AD4B677.4000308@embedded.ufcg.edu.br>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

First Patch on TFRC-SP. Does a copy from TFRC and adjust symbols name
with infix "_sp".
Also updates Kconfig and init/exit code. An #ifndef was added to headers
that
have commom symbols with TFRC that were not changed, so they don't get
included twice.


Following the rule #8 in Documentation/SubmittingPatches the patch is
stored at
http://embedded.ufcg.edu.br/~ivocalado/dccp/patches/patches_tfrc_sp_receiver-v2/tfrc_sp_receiver_01.patch

