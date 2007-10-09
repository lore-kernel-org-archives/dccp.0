From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Tue, 09 Oct 2007 02:13:02 +0000
Subject: DCCP feature negotiation via setsockopt/getsockopt
Message-Id: <5bc4c4570710081913hd9abfdek5bee586393ef1f72@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Well, I'm very closer to release the first version of dccp plugin for
gstreamer and I want to ask you something related to feature
negotiation, which gerrit recently submitted patches related to this
last week...
 In the gstreamer plugin I want to provide a plugin property named
ccid, where the programmer will set or get the current ccid. Is dccp
implementation for linux already prepared to support this mechanism
through feature negotiation (or something related via
setsockopt/getsockopt)?

Leandro.
