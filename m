From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 17 Nov 2008 15:31:55 +0000
Subject: Re: [PATCH 2/5] dccp: Deprecate old setsockopt framework
Message-Id: <20081117153155.GA3446@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1226751079-15019-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1226751079-15019-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > This patch removes the old setsockopt interface and replaces it with two new
| > functions to register NN/SP values for feature negotiation. 
<snip>
| But you have to understand that this is something you should think
| about never doing again.  User interfaces are never "oops sorry, we
| misdesigned that, we'll just take it away and emit some warning,
| fix your app"  Once it's out there, you gotta support it forever.
| 

I hope that the present solution of replacing is sufficient since there was
at least one crash reported with the old interface, on
http://www.spinics.net/lists/dccp/msg03371.html

Later within the patch set (not in the current submission) there is also a 
setsockopt warning that the old interface is no longer valid (in the patch
"dccp: Deprecate old setsockopt framework" on http://eden-feed.erg.abdn.ac.uk).

With regard to interface changes, it would be best/easier to keep them within
one release. I am not up-to-date how long net-next-2.6 will remain open,
but if you are pushing it out soon, it would be best not to push out the old
and the new interface in parallel.

I am otherwise happy to resubmit the reviewed patches again later, as
already done after the last merge window.

With regard to compilation there are no concerns, patches are all tested to
compile standalone.

Please let me know how you would like to proceed.

Gerrit
