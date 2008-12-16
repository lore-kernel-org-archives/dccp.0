From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 16 Dec 2008 05:55:41 +0000
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
Message-Id: <20081216055540.GC6199@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | > +static int ccid_request_module(u8 id)
| > | > +{
| > | > +       if (!in_atomic()) {
| > | > +               ccids_read_lock();
| > | > +               if (ccids[id] = NULL) {
| > | > +                       ccids_read_unlock();
| > | > +                       return request_module("net-dccp-ccid-%d", id);
| > | > +               }
| > | > +               ccids_read_unlock();
| > | > +       }
| > | > +       return 0;
| > | > +}
| > |
| > | Just a random thought: does this lock really do anything useful here?
| > |
| > Reading the (shared) 'ccids' array is the solution chosen to check whether
| > the module for CCID with number 'id' is already loaded.
| >
| > It would be bad to call request_module() each time a new DCCP socket is
| > opened. Using the 'ccids' array may not be the only way to check whether
| > a given module (whose name depends on the value of 'id') is loaded.
| >
| > But if this solution is chosen, then it requires to protect the read
| > access to 'ccids', which is shared among all DCCP sockets.
| 
| Since the lock is dropped after checking ccids[id] then there's
| a window where multiple request_module()s can be called if multiple
| applications create a DCCP socket at a same time. The code below
| should do the same without a lock (ccids is a static array,
| so ccids[N] is always at the same place).
| 
| static int ccid_request_module(u8 id)
| {
|        if (!in_atomic()) {
|                rmb();
|                if (ccids[id] = NULL)
|                        return request_module("net-dccp-ccid-%d", id);
|        }
|        return 0;
| }
| 
Sorry Michael, but this is really just a "random thought". What you are
in effect saying is that reader/writer locks can be replaced with just a
read memory barrier.

Please have a more detailed look at net/dccp/ccid.c. I also checked how
other subsystems handle comparable situations of module loading: the 
implementation details differ, but the principle is the same: there are
mutexes, semaphores, and spinlocks in use to protect those shared
structures that are related to the loaded module.

Hence your suggestion does not improve the code. I maintain that it is
correct. And it has proven to work in the test tree for more than one
year, including tests with up to 100 parallel (iperf) connections.
