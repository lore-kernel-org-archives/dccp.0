From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Tue, 06 Jan 2009 01:17:29 +0000
Subject: Re: dccp test tree [RFC/RFT] [Patch 1/3] dccp: minor Kconfig cosmetics
Message-Id: <39e6f6c70901051717p33da63b2ra8dade1da945624@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20090105144213.GB3773@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20090105144213.GB3773@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Jan 5, 2009 at 11:06 PM, Wei Yongjun <yjwei@cn.fujitsu.com> wrote:
> Gerrit Renker wrote:

>> +         value. Values in units of milliseconds can be set here.
>> +
>> +         A value of 0 disables this feature by enforcing the value
>> specified
>> +         in RFC 5448. The following values have been suggested as bounds
>> for
>>
>
> RFC 5448 should be RFC 5348.

Indeed.

- Arnaldo
