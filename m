From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Tue, 09 Oct 2007 02:05:02 +0000
Subject: CCID3 and CCID4 share code status
Message-Id: <5bc4c4570710081905t3838da79w52f921d7b1d540a1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

 I'm almost finishing the initial release of the dccp plugin for
gstreamer and the integration patches of both, ccid3 and ccid4 (still
with basic changes from ccid3) according to discussed in the mail
list. Since gerrit changed the ccid3 module source code, I had to
update the ccid4 code too. Due to this situation, it will be very
interesting if we have as soon as possible the common lib to share
common codes between ccid3 and ccid4, and this is my current job. Just
FYI, I'm organizing the code according to arnaldo and gerrit
suggestions, to use a separated source file, which I named it for
ccid34_commons.c/h and link it in the Makefile of ccids/lib via trfc
module, is this the correct way gerrit, accoding to your suggestion? I
added the ccid34_commons.o in the trfc lib Makefile.
 I already tested the solution and seems to be ok, but I need to
provide some fixes to finally submit the patches. I think that this
will happen in two more days, since I'm still a little bit busy with
stuffs related to academic activities.

Leandro.
