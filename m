From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 13 Dec 2008 14:56:55 +0000
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
Message-Id: <20081213145655.GA14240@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > +static int ccid_request_module(u8 id)
| > +{
| > +       if (!in_atomic()) {
| > +               ccids_read_lock();
| > +               if (ccids[id] = NULL) {
| > +                       ccids_read_unlock();
| > +                       return request_module("net-dccp-ccid-%d", id);
| > +               }
| > +               ccids_read_unlock();
| > +       }
| > +       return 0;
| > +}
| 
| Just a random thought: does this lock really do anything useful here?
| 
Reading the (shared) 'ccids' array is the solution chosen to check whether
the module for CCID with number 'id' is already loaded.

It would be bad to call request_module() each time a new DCCP socket is
opened. Using the 'ccids' array may not be the only way to check whether
a given module (whose name depends on the value of 'id') is loaded. 

But if this solution is chosen, then it requires to protect the read
access to 'ccids', which is shared among all DCCP sockets.
