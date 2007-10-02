From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 02 Oct 2007 10:04:34 +0000
Subject: Re: [PATCH 3/3]: Convert Reset code into socket error number
Message-Id: <200710021104.34922@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709291744.53552@strip-the-willow>
In-Reply-To: <200709291744.53552@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > +static u8 dccp_reset_code_convert(const u8 code)
|  > +{
|  > +       const u8 error_code[] = {
|  > +       [DCCP_RESET_CODE_CLOSED]             = 0,       /* normal termination */
|  > +       [DCCP_RESET_CODE_UNSPECIFIED]        = 0,       /* nothing known */
|  > +       [DCCP_RESET_CODE_ABORTED]            = ECONNRESET,
|  > +
|  > +       [DCCP_RESET_CODE_NO_CONNECTION]      = ECONNREFUSED,
|  > +       [DCCP_RESET_CODE_CONNECTION_REFUSED] = ECONNREFUSED,
|  > +       [DCCP_RESET_CODE_TOO_BUSY]           = EUSERS,
|  > +       [DCCP_RESET_CODE_AGGRESSION_PENALTY] = EDQUOT,
|  > +
|  > +       [DCCP_RESET_CODE_PACKET_ERROR]       = ENOMSG,
|  > +       [DCCP_RESET_CODE_BAD_INIT_COOKIE]    = EBADR,
|  > +       [DCCP_RESET_CODE_BAD_SERVICE_CODE]   = EBADRQC,
|  > +       [DCCP_RESET_CODE_OPTION_ERROR]       = EILSEQ,
|  > +       [DCCP_RESET_CODE_MANDATORY_ERROR]    = EOPNOTSUPP,
|  > +       };
|  > +
|  
|  This array is inside the function so is local.
|  
|  > +       return code <= DCCP_RESET_CODE_AGGRESSION_PENALTY? error_code[code] : 0;
|  
|  and then you basically don't use half of it.
|  > +}
|
There is no problem declaring a local array here and I don't understand what you mean by
"basically don't use half of it" -- all are valid reset codes and all can appear on a
DCCP connection. 

|  So I presume the reason for doing this is that half the codes don't
|  apply to reset.
Please have a look at RFC 4340, 5.6.
 
|  As such then the array should be shifted out of the local function
|  into the main part of the file.
For a standalone table one would have to perform the index-bounds test each time which I think
is pretty bad, as the caller should not have to know about internals and bounds of Reset Codes.
Also we are not yet at the end of the story of reset codes - have you thought about dealing with
Data Dropped options - this is a different way of generating error codes: Drop code 1, "Application 
Not Listening", for instance has an effect similar to EPIPE (11.7). 
By using separate functions for translating the results, one can keep this separate.

NB: In the test tree I have changed the index-bounds test to 

 return code > DCCP_RESET_CODE_AGGRESSION_PENALTY ?  0 : error_code[code];

due to
	(a) coding conventions (Arnaldos email)
	(b) the reset codes 12-127 (reserved) and 128-255, CCID-specific codes, are
            to be interpreted as `0', "Unspecified" and is now clearer in the above.

