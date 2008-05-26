From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 26 May 2008 14:22:09 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080526142209.GA20164@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | I don't like the "highest supported ID" approach. But if you don't like
| > | arrays a simple "bool getsockopt" would do, we could just ask the kernel
| > | if it supports given qpolicy. Like (in pseudocode):
| > | bool
| > | supports_prio=getsockopt(sk,DCCP_SOCKOPT_QPOLICY_AVAILABLE,QPOLICY_PRIO);
| > | Would that be ok?
| >
| > What I sent is just a sketch, nothing set in stone. I am happy to take
| > my patch out of the repository if there are better solutions.
| >
| The question is: would you consider such a solution better? 
| 
I think it is too early for this question, it needs some practical experience.
It may be that a third or fourth solution proves more useful.


| > Hence I am trying to figure out - how much change is due to re-designing
| > things and how much change is de facto required for a useful dynamic
| > interface?
| >
| IMO we could divide the interface into two parts:
|  - operations - they are likely to stabilize before pushing the code to 
| mainline,
|  - parameters (all kinds of numbers like DCCP_SCM_xxx, qpolicy ids, etc.) - 
| there should always be a room for new ones (and maybe even deleting old 
| ones). And one should be able to verify which numbers are valid - that's why 
| we need operations for this purpose that are available from the very 
| beginning.
| 
I think this problem appears in other kernel areas as well, such as
finding consistent identifiers for identifiers, flags, symbolic names.

Haven't grepped through, but there is likely a smart solution available
already somewhere. 

For IETF specifications, the IANA handles all numbers that appear in
packets, a similar thing appears here. But with some discipline it
should not cause a problem. 


| I have nothing against creating generic interface for obtaining information 
| about various aspects of dccp. But I can't see how netlink can help us here. 
| From the documents I've read I understand that generic netlink requires you 
| to create a special kind of socket type and then you can send or receive 
| information through it. But it seems to be something separate from dccp 
| sockets.
| 
Yes, the netlink socket would be different from the DCCP socket and it
is actually a good point - it shows that this interface can only be used
for global parameters or settings. Or maybe there is a way of
associating both sockets.


| As for information we can get from kernel wrt dccp we have at least:
| 1. fixed information that depends only on kernel version. For example list of 
| ccids, list of available qpolicies, list of parameters for given qpolicy, 
| etc. These are system wide and don't need reference to socket. These could 
| even be exposed by read-only entries in /sys or /proc.
That is a good point - I think Arnaldo had a similar idea once for implenting
system-wide policies regarding which CCIDs are supported. Something like
net.ipv4.tcp_available_congestion_control.

| 2. typical socket options. Among others: currently used rx/tx ccid, currently 
| used qpolicy, queue and buffer sizes, etc. For these we need reference to 
| socket and get/setsockopts are the natural choice. And I guess no changes 
| should happen here.
Agree.

| 3. statistics. These are not options in the sense that you cannot set them. 
| You also cannot expect that two consecutive reads will return the same value. 
| They depend on certain asynchronous events in various parts of dccp code. The 
| first question is: should we pass those raw events to applications (such 
| as "prio qpolicy: packet dropped") or aggregate data ("in the last 100 
| packets 17 were dropped before sending")? For this kind of information we 
| need reference to socket (struct sock *). And I can't see how we could obtain 
| it from functions not mentioned in struct proto.
| 
It was for this part that I looked at netlink. This goes into the
direction of a new API or at least API extensions.

For global statistics there is already the DCCP MIB, but it needs some
more work (in /proc/snmp there are no entries at the moment), a ToDo.

For per-socket statistics there is indeed a need for a notification
mechanism. If a synchronous mechanism is sufficient, then something like
the current CCID-3 getsockopt(DCCP_SOCKOPT_CCID_{RX,TX}_INFO) can be used.

For asynchronous notification, using a special signal comes to mind,
where the application installs a signal handler as notifier.

The best that I can think of is to map a segment of userspace memory
into the kernel and use this memory area as a (ready-only) statistics
struct. That would save the system call overhead of using getsockopt().

That is my list of ideas at the moment. Probably not exhaustive.

- Gerrit
