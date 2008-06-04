From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 04 Jun 2008 15:09:42 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080604150942.GA4980@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Now that I had a closer look at implementing this functionality I have a few 
| questions:
| 1. Where should information about available qpolicies and their parametrs be 
| exported? Would /proc/net/dccp/qpolicies/ be a good choice?
For a sketch or a first implementation, procfs sounds like a good starting point.

But since it is about dynamic runtime configuration, how about using sysfs or configfs
instead? This is a brainstorming question, I think that sysfs is generally preferred.
I don't know how well configfs has taken off, it is similar, but needs to be
added in the configuration (under Pseudeo Filesystems, CONFIG_CONFIGFS_FS=y|m)
http://lwn.net/Articles/148973/
and Documentation/filesystems/configs. But this could be done later as well.


| 2. I guess we should have at least one file per qpolicy with parameters listed 
| inside. Like that:
| /proc/.../qpolicies/simple: <empty>
| /proc/.../qpolicies/prio: 1 (DCCP_SCM_PRIORITY) 2 (DCCP_SCM_TIMEOUT)
Hm this is a "policy" question -- isn't the `timeout' policy a
standalone variant?

| But we could also have qpolicy represented by directory and parameters by files:
| /proc/.../qpolicies/simple/
| /proc/.../qpolicies/prio/
| /proc/.../qpolicies/prio/priority: <empty>
| /proc/.../qpolicies/prio/timeout: <empty>
| Which layout do you find better?
| -- 
I don't like the empty files. In the procfs for thinkpad Acpi
configuration, for example, there is a line that says which commands are
acceptable, similar for /sys/power/state. In that way, the (sysfs|procfs) file
documents itself and tells the user what can be done with it. It would
be great if the qpolicies could do something similar.

I would start with the utterly simplest possible implementation and
leave complex cases for later. For a sophisticated, elegant
implementation, I would seriously consider sysfs or configs.
