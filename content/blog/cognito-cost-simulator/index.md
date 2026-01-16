---
title: "AWS Cognito M2M Cost Simulator"
date: 2026-01-16T00:00:00+09:00
description: "AWS Cognito M2M 인증 비용을 시뮬레이션하는 계산기"
tags: ["aws", "cognito"]
extra:
  showAdvertisement: false
---

<style>
.simulator{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;max-width:900px;margin:0 auto;font-size:14px;color:#e5e7eb}
.simulator *{box-sizing:border-box}
.sim-header{margin-bottom:1rem}
.sim-header p{font-size:.75rem;color:#9ca3af;margin:0}
.arch-diagram{background:linear-gradient(to right,#1f2937,#111827);padding:1rem;border-radius:.5rem;margin-bottom:1rem;overflow-x:auto;border:1px solid #374151}
.arch-title{font-size:.75rem;color:#9ca3af;font-weight:600;margin-bottom:.5rem;margin-top:0}
.arch-flow{display:flex;align-items:flex-start;justify-content:flex-start;gap:.125rem;min-width:max-content;font-size:.75rem}
.arch-item{display:flex;flex-direction:column;align-items:center}
.arch-box{padding:.5rem .75rem;border-radius:.5rem;font-weight:500;box-shadow:0 2px 4px rgba(0,0,0,0.3);min-height:52px;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;color:white;gap:.25rem}
.arch-box svg{width:24px;height:24px;fill:currentColor;stroke:currentColor;stroke-width:1.5;stroke-linecap:round;stroke-linejoin:round}
.arch-box.idc{background:#475569}
.arch-box.dx{background:#7c3aed}
.arch-box.tgw{background:#ea580c}
.arch-box.vpce{background:#059669}
.arch-box.cognito{background:#d97706}
.arch-cost{padding:.125rem .5rem;border-radius:.25rem;margin-top:.25rem;font-weight:bold;font-size:.75rem}
.arch-cost.dx{background:#2e1065;color:#c4b5fd}
.arch-cost.tgw{background:#431407;color:#fdba74}
.arch-cost.vpce{background:#022c22;color:#6ee7b7}
.arch-cost.cognito{background:#451a03;color:#fcd34d}
.arch-detail{color:#6b7280;margin-top:.125rem;text-align:center;line-height:1.3;font-size:.7rem}
.arch-arrow{display:flex;flex-direction:column;align-items:center;justify-content:center;padding-top:1rem;color:#9ca3af}
.arch-arrow-icon{background:#374151;border:1px solid #4b5563;border-radius:.25rem;padding:.125rem .375rem;color:#d1d5db}
.arch-arrow-label{color:#9ca3af;font-weight:500}
.vpc-wrapper{border:2px dashed #059669;border-radius:.5rem;padding:.375rem;background:#022c22}
.vpc-label{color:#6ee7b7;font-weight:500;margin-bottom:.25rem;text-align:center;font-size:.75rem}
.total-box{margin-top:1rem;background:#111827;border-radius:.5rem;padding:.75rem;border:1px solid #374151}
.total-header{display:flex;justify-content:space-between;align-items:center}
.total-label{font-weight:bold;color:#e5e7eb}
.total-value{font-size:1.5rem;font-weight:bold;color:#60a5fa}
.total-krw{font-size:.75rem;color:#9ca3af;margin-left:.5rem}
.cost-bar{margin-top:.5rem;height:2.5rem;border-radius:.5rem;overflow:hidden;display:flex;background:#1f2937}
.cost-bar-segment{display:flex;flex-direction:column;align-items:center;justify-content:center;color:white;font-size:.65rem;line-height:1.2}
.cost-bar-segment.dx{background:#8b5cf6}
.cost-bar-segment.tgw{background:#f97316}
.cost-bar-segment.vpce{background:#10b981}
.cost-bar-segment.m2m{background:#f59e0b}
.cost-legend{display:flex;flex-wrap:wrap;gap:1rem;margin-top:.25rem;font-size:.75rem;color:#9ca3af}
.cost-legend-item{display:flex;align-items:center}
.cost-legend-dot{width:.5rem;height:.5rem;border-radius:.25rem;margin-right:.25rem;display:inline-block}
.cost-legend-dot.dx{background:#8b5cf6}
.cost-legend-dot.tgw{background:#f97316}
.cost-legend-dot.vpce{background:#10b981}
.cost-legend-dot.m2m{background:#f59e0b}
.input-grid{display:grid;grid-template-columns:1fr;gap:1rem;margin-top:1rem}
.input-panel,.detail-panel{background:#1f2937;padding:.75rem;border-radius:.5rem;border:1px solid #374151}
.panel-title{font-weight:600;margin-bottom:.5rem;margin-top:0;color:#e5e7eb;font-size:.875rem}
.input-field{margin-bottom:.75rem}
.input-label{display:block;font-size:.75rem;font-weight:500;color:#d1d5db;margin-bottom:.25rem}
.input-value{color:#60a5fa;font-weight:bold}
.input-range{width:100%;height:.5rem;background:#374151;border-radius:.5rem;cursor:pointer;-webkit-appearance:none}
.input-range::-webkit-slider-thumb{-webkit-appearance:none;width:1rem;height:1rem;background:#60a5fa;border-radius:50%;cursor:pointer}
.input-select{width:100%;padding:.5rem;border:1px solid #374151;border-radius:.25rem;font-size:.75rem;background:#111827;color:#e5e7eb}
.detail-table{width:100%;font-size:.75rem;border-collapse:separate;border-spacing:0}
.detail-table th{text-align:left;padding:.5rem .75rem;background:#374151;color:#e5e7eb;font-weight:600;border:none}
.detail-table th:first-child{border-radius:.5rem 0 0 0}
.detail-table th:last-child{border-radius:0 .5rem 0 0}
.detail-table th:nth-child(2),.detail-table th:nth-child(3){text-align:right}
.detail-table td{padding:.625rem .75rem;border-bottom:1px solid #374151;background:#1f2937;color:#e5e7eb}
.detail-table td:nth-child(2),.detail-table td:nth-child(3){text-align:right}
.detail-table .sub-row td{padding-left:1.5rem;color:#9ca3af;background:#111827}
.detail-table .total-row td{background:linear-gradient(135deg,#1e3a5f,#1e40af);border-bottom:none;font-weight:700;color:#fff}
.detail-table .total-row td:first-child{border-radius:0 0 0 .5rem}
.detail-table .total-row td:last-child{border-radius:0 0 .5rem 0}
.detail-table tbody tr:hover td{background:#374151}
.m2m-pricing{margin-top:1rem;background:#292524;padding:.75rem;border-radius:.5rem;font-size:.75rem;border:1px solid #44403c}
.m2m-title{font-weight:600;color:#fbbf24;margin-bottom:.5rem;margin-top:1rem}
.m2m-title a{color:#fbbf24}
.m2m-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:.5rem;color:#fcd34d}
.m2m-tier{background:#1c1917;padding:.5rem;border-radius:.25rem;text-align:center;border:1px solid #44403c}
.m2m-tier-label{font-weight:bold;color:#fbbf24}
.m2m-note{margin-top:.5rem;color:#a8a29e}
.notes-section{margin-top:.75rem;background:#1f2937;padding:.75rem;border-radius:.5rem;font-size:.75rem;color:#9ca3af;border:1px solid #374151}
.notes-title{font-weight:600;margin-bottom:.5rem;margin-top:.75rem;color:#e5e7eb}
.notes-list{margin:0;padding:0;list-style:none}
.notes-list li{margin-bottom:.125rem}
.region-wrapper{border:2px dashed #f97316;border-radius:.75rem;padding:.5rem;background:rgba(249,115,22,0.05);position:relative;margin:0 .25rem}
.region-label{position:absolute;top:-.5rem;left:.75rem;background:#111827;padding:0 .5rem;color:#fb923c;font-size:.65rem;font-weight:600}
.region-content{display:flex;align-items:flex-start;gap:.125rem}
</style>

<div class="simulator">
<div style="text-align:right;font-size:.65rem;color:#6b7280;margin-bottom:.5rem;">v0.1.0</div>
<p class="arch-title">Architecture & Cost Breakdown (M2M Authentication)</p>
<div class="arch-diagram">
<div class="arch-flow">
<div class="arch-item">
<div class="arch-box idc"><svg viewBox="0 0 24 24"><path d="M4 6h16v2H4zm0 5h16v2H4zm0 5h16v2H4z"/></svg>IDC</div>
<div class="arch-detail">Client</div>
</div>
<div class="arch-arrow">
<span>→</span>
<span style="font-size:0.7rem;color:#6b7280;">BGP</span>
</div>
<div class="region-wrapper">
<div class="region-label">AWS ap-northeast-2 (Seoul)</div>
<div class="region-content">
<div class="arch-item">
<div class="arch-box dx"><svg viewBox="0 0 24 24"><path d="M12 2L2 7v10l10 5 10-5V7L12 2zm0 2.5L19 8l-7 3.5L5 8l7-3.5zM4 9.5l7 3.5v6.5l-7-3.5V9.5zm16 0v6.5l-7 3.5v-6.5l7-3.5z"/></svg>DX</div>
<div class="arch-cost dx">$<span id="dx-total">87.60</span>/mo</div>
<div class="arch-detail">Port: $<span id="dx-port">87.60</span><br>DTI: Free<br>DTO: $<span id="dx-dto">0.00</span></div>
</div>
<div class="arch-arrow">
<div class="arch-arrow-icon">↔</div>
<div class="arch-arrow-label"><span id="data-gb">1.43</span>GB</div>
</div>
<div class="arch-item">
<div class="arch-box tgw"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M12 2v4m0 12v4M2 12h4m12 0h4M4.93 4.93l2.83 2.83m8.48 8.48l2.83 2.83M4.93 19.07l2.83-2.83m8.48-8.48l2.83-2.83"/></svg>TGW</div>
<div class="arch-cost tgw">$<span id="tgw-total">102.23</span>/mo</div>
<div class="arch-detail">Attach: $<span id="tgw-attach">102.20</span><br>Data (In+Out): $<span id="tgw-data">0.03</span></div>
</div>
<div class="arch-arrow">
<div class="arch-arrow-icon">↔</div>
</div>
<div class="arch-item">
<div class="vpc-wrapper">
<div class="vpc-label">VPC</div>
<div class="arch-box vpce"><svg viewBox="0 0 24 24"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>VPCE</div>
</div>
<div class="arch-cost vpce">$<span id="vpce-total">18.99</span>/mo</div>
<div class="arch-detail">Hourly: $<span id="vpce-hourly">18.98</span><br>Data (In+Out): $<span id="vpce-data">0.01</span></div>
</div>
<div class="arch-arrow">
<div class="arch-arrow-icon" style="background:#1e3a5f;border-color:#3b82f6;color:#60a5fa;">↔</div>
<div style="color:#60a5fa;font-weight:500;">Backbone</div>
</div>
<div class="arch-item">
<div class="arch-box cognito"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>Cognito</div>
<div class="arch-cost cognito">$<span id="m2m-cost">102.50</span>/mo</div>
<div class="arch-detail">Client Credentials<br><span id="m2m-requests">500,000</span> req</div>
</div>
</div>
</div>
<div class="arch-arrow">
<span style="color:#16a34a;">←</span>
<span style="color:#16a34a;font-weight:500;">JWT</span>
</div>
</div>
<div class="total-box">
<div class="total-header">
<span class="total-label">Total Monthly Cost</span>
<div style="text-align:right;">
<div><span class="total-value">$<span id="total-monthly">311.32</span></span></div>
<div style="color:#fbbf24;font-size:1rem;font-weight:bold;">&#8361;<span id="total-krw">451,414</span></div>
</div>
</div>
<div class="cost-bar">
<div class="cost-bar-segment dx" id="bar-dx" style="width:28%">DX<br><span id="pct-dx">28%</span></div>
<div class="cost-bar-segment tgw" id="bar-tgw" style="width:33%">TGW<br><span id="pct-tgw">33%</span></div>
<div class="cost-bar-segment vpce" id="bar-vpce" style="width:6%">VPCE<br><span id="pct-vpce">6%</span></div>
<div class="cost-bar-segment m2m" id="bar-m2m" style="width:33%">M2M<br><span id="pct-m2m">33%</span></div>
</div>
<div class="cost-legend">
<span class="cost-legend-item"><span class="cost-legend-dot dx"></span>DX: $<span id="legend-dx">87.60</span></span>
<span class="cost-legend-item"><span class="cost-legend-dot tgw"></span>TGW: $<span id="legend-tgw">102.23</span></span>
<span class="cost-legend-item"><span class="cost-legend-dot vpce"></span>VPCE: $<span id="legend-vpce">18.99</span></span>
<span class="cost-legend-item"><span class="cost-legend-dot m2m"></span>M2M: $<span id="legend-m2m">102.50</span></span>
</div>
</div>
</div>
<div class="input-grid">
<h2 class="panel-title">Input Parameters</h2>
<div class="input-panel">
<div class="input-field">
<label class="input-label">Exchange Rate (USD/KRW): <span class="input-value" id="label-rate">1,450</span></label>
<input type="range" class="input-range" id="input-rate" min="1450" max="1500" step="10" value="1450">
</div>
<div class="input-field">
<label class="input-label">M2M Token Requests (monthly): <span class="input-value" id="label-requests">500,000</span> req</label>
<input type="range" class="input-range" id="input-requests" min="10000" max="10000000" step="10000" value="500000">
</div>
<div class="input-field">
<label class="input-label">Request Size (In): <span class="input-value" id="label-size">3</span> KB</label>
<input type="range" class="input-range" id="input-size" min="0.5" max="10" step="0.5" value="3">
</div>
<div class="input-field">
<label class="input-label">Response Size (Out): <span class="input-value" id="label-resp">1.5</span> KB</label>
<input type="range" class="input-range" id="input-resp" min="0.5" max="10" step="0.5" value="1.5">
</div>
<div class="input-field">
<label class="input-label">VPC Endpoint AZ Count: <span class="input-value" id="label-az">2</span></label>
<input type="range" class="input-range" id="input-az" min="1" max="3" step="1" value="2">
</div>
<div class="input-field">
<label class="input-label">DX Hosted Capacity (per line): <span class="input-value" id="label-dx">100 Mbps ($0.06/hr)</span></label>
<input type="range" class="input-range" id="input-dx" min="0" max="5" step="1" value="1">
</div>
</div>
<h2 class="panel-title">Cost Breakdown</h2>
<div class="detail-panel">
<table class="detail-table">
<thead>
<tr>
<th>Item</th>
<th>Unit Price</th>
<th>Monthly Cost</th>
</tr>
</thead>
<tbody>
<tr>
<td><span class="cost-legend-dot dx"></span>DX Port (x2)</td>
<td style="color:#6b7280;" id="td-dx-unit">$0.06/hr x2</td>
<td style="font-weight:500;">$<span id="td-dx-port">87.60</span></td>
</tr>
<tr class="sub-row" >
<td>- DTI (In)</td>
<td style="color:#6b7280;">Free</td>
<td>$0.00</td>
</tr>
<tr class="sub-row" >
<td>- DTO (Out)</td>
<td style="color:#6b7280;">$0.041/GB</td>
<td>$<span id="td-dx-dto">0.00</span></td>
</tr>
<tr>
<td><span class="cost-legend-dot tgw"></span>TGW Attach (x2)</td>
<td style="color:#6b7280;">$0.07/hr x2</td>
<td style="font-weight:500;">$<span id="td-tgw-attach">102.20</span></td>
</tr>
<tr class="sub-row" >
<td>- Data (In+Out)</td>
<td style="color:#6b7280;">$0.02/GB</td>
<td>$<span id="td-tgw-data">0.03</span></td>
</tr>
<tr>
<td><span class="cost-legend-dot vpce"></span>VPCE (<span id="td-vpce-az">2</span>AZ)</td>
<td style="color:#6b7280;">$0.013/hr x<span id="td-vpce-az2">2</span></td>
<td style="font-weight:500;">$<span id="td-vpce-hourly">18.98</span></td>
</tr>
<tr class="sub-row" >
<td>- Data (In+Out)</td>
<td style="color:#6b7280;">$0.01/GB</td>
<td>$<span id="td-vpce-data">0.01</span></td>
</tr>
<tr >
<td><span class="cost-legend-dot m2m"></span>Cognito M2M</td>
<td style="color:#6b7280;"><span id="td-m2m-req">500,000</span> req</td>
<td style="font-weight:500;">$<span id="td-m2m-cost">102.50</span></td>
</tr>
<tr class="total-row">
<td colspan="2">Total Monthly Cost</td>
<td style="color:#2563eb;font-size:0.875rem;">$<span id="td-total">311.32</span></td>
</tr>
</tbody>
</table>
</div>
</div>
<h3 class="m2m-title"><a href="https://aws.amazon.com/about-aws/whats-new/2025/11/amazon-cognito-removes-machine-machine-app-client-price-dimension/" target="_blank">Cognito M2M Pricing (Nov 2025~)</a></h3>
<div class="m2m-pricing">
<div class="m2m-grid">
<div class="m2m-tier">
<div class="m2m-tier-label">~100K</div>
<div>$2.25/10K</div>
</div>
<div class="m2m-tier">
<div class="m2m-tier-label">100K~1M</div>
<div>$2.00/10K</div>
</div>
<div class="m2m-tier">
<div class="m2m-tier-label">1M~10M</div>
<div>$0.80/10K</div>
</div>
<div class="m2m-tier">
<div class="m2m-tier-label">10M+</div>
<div>$0.50/10K</div>
</div>
</div>
<p class="m2m-note"><span style="color:#4ade80;font-weight:600;">Good News:</span> App Client fee removed (previously: $6/mo/Client)</p>
</div>
<h3 class="notes-title">Notes</h3>
<div class="notes-section">
<ul class="notes-list">
<li>* DX DTI (In: IDC→AWS): Free | DTO (Out: AWS→IDC): $0.041/GB</li>
<li>* M2M has no MAU charges (system-to-system auth, not user auth)</li>
<li>* Token caching recommended (default token validity: 1 hour)</li>
</ul>
</div>
</div>

<script>
(function(){
var dxOptions=[{key:'50M',label:'50 Mbps',rate:0.03},{key:'100M',label:'100 Mbps',rate:0.06},{key:'200M',label:'200 Mbps',rate:0.08},{key:'300M',label:'300 Mbps',rate:0.12},{key:'500M',label:'500 Mbps',rate:0.20},{key:'1G',label:'1 Gbps',rate:0.33}];
var m2mPricing=[{limit:100000,rate:2.25},{limit:1000000,rate:2.00},{limit:10000000,rate:0.80},{limit:Infinity,rate:0.50}];
var hoursPerMonth=730;
function calculate(){
var m2mTokenRequests=parseInt(document.getElementById('input-requests').value);
var requestSizeKB=parseFloat(document.getElementById('input-size').value);
var responseSizeKB=parseFloat(document.getElementById('input-resp').value);
var azCount=parseInt(document.getElementById('input-az').value);
var dxIndex=parseInt(document.getElementById('input-dx').value);
var dxCapacity=dxOptions[dxIndex];
var exchangeRate=parseInt(document.getElementById('input-rate').value);
var dataInGB=(m2mTokenRequests*requestSizeKB)/1024/1024;
var dataOutGB=(m2mTokenRequests*responseSizeKB)/1024/1024;
var dataTotalGB=dataInGB+dataOutGB;
var dxPortHourly=dxCapacity.rate*2*hoursPerMonth;
var dxDTO=dataOutGB*0.0410;
var dxTotal=dxPortHourly+dxDTO;
var tgwAttachmentHourly=0.07*2*hoursPerMonth;
var tgwDataProcessing=dataTotalGB*0.02;
var tgwTotal=tgwAttachmentHourly+tgwDataProcessing;
var vpceHourly=0.013*azCount*hoursPerMonth;
var vpceDataProcessing=dataTotalGB*0.01;
var vpceTotal=vpceHourly+vpceDataProcessing;
var m2mCost=0;
var remaining=m2mTokenRequests;
var prevLimit=0;
for(var i=0;i<m2mPricing.length;i++){
var tier=m2mPricing[i];
var tierAmount=Math.min(remaining,tier.limit-prevLimit);
if(tierAmount>0){m2mCost+=(tierAmount/10000)*tier.rate;remaining-=tierAmount;}
prevLimit=tier.limit;
if(remaining<=0)break;
}
var totalMonthly=dxTotal+tgwTotal+vpceTotal+m2mCost;
document.getElementById('label-requests').textContent=m2mTokenRequests.toLocaleString();
document.getElementById('label-size').textContent=requestSizeKB;
document.getElementById('label-resp').textContent=responseSizeKB;
document.getElementById('label-az').textContent=azCount;
document.getElementById('label-dx').textContent=dxCapacity.label+' ($'+dxCapacity.rate+'/hr)';
document.getElementById('dx-total').textContent=dxTotal.toFixed(2);
document.getElementById('dx-port').textContent=dxPortHourly.toFixed(2);
document.getElementById('dx-dto').textContent=dxDTO.toFixed(2);
document.getElementById('data-gb').textContent=dataOutGB.toFixed(2);
document.getElementById('tgw-total').textContent=tgwTotal.toFixed(2);
document.getElementById('tgw-attach').textContent=tgwAttachmentHourly.toFixed(2);
document.getElementById('tgw-data').textContent=tgwDataProcessing.toFixed(2);
document.getElementById('vpce-total').textContent=vpceTotal.toFixed(2);
document.getElementById('vpce-hourly').textContent=vpceHourly.toFixed(2);
document.getElementById('vpce-data').textContent=vpceDataProcessing.toFixed(2);
document.getElementById('m2m-cost').textContent=m2mCost.toFixed(2);
document.getElementById('m2m-requests').textContent=m2mTokenRequests.toLocaleString();
document.getElementById('total-monthly').textContent=totalMonthly.toFixed(2);
document.getElementById('label-rate').textContent=exchangeRate.toLocaleString();
document.getElementById('total-krw').textContent=Math.round(totalMonthly*exchangeRate).toLocaleString();
var dxPct=(dxTotal/totalMonthly)*100;
var tgwPct=(tgwTotal/totalMonthly)*100;
var vpcePct=(vpceTotal/totalMonthly)*100;
var m2mPct=(m2mCost/totalMonthly)*100;
document.getElementById('bar-dx').style.width=dxPct+'%';
document.getElementById('bar-tgw').style.width=tgwPct+'%';
document.getElementById('bar-vpce').style.width=vpcePct+'%';
document.getElementById('bar-m2m').style.width=m2mPct+'%';
document.getElementById('pct-dx').textContent=Math.round(dxPct)+'%';
document.getElementById('pct-tgw').textContent=Math.round(tgwPct)+'%';
document.getElementById('pct-vpce').textContent=Math.round(vpcePct)+'%';
document.getElementById('pct-m2m').textContent=Math.round(m2mPct)+'%';
document.getElementById('legend-dx').textContent=dxTotal.toFixed(2);
document.getElementById('legend-tgw').textContent=tgwTotal.toFixed(2);
document.getElementById('legend-vpce').textContent=vpceTotal.toFixed(2);
document.getElementById('legend-m2m').textContent=m2mCost.toFixed(2);
document.getElementById('td-dx-unit').textContent='$'+dxCapacity.rate+'/hr x2';
document.getElementById('td-dx-port').textContent=dxPortHourly.toFixed(2);
document.getElementById('td-dx-dto').textContent=dxDTO.toFixed(2);
document.getElementById('td-tgw-attach').textContent=tgwAttachmentHourly.toFixed(2);
document.getElementById('td-tgw-data').textContent=tgwDataProcessing.toFixed(2);
document.getElementById('td-vpce-az').textContent=azCount;
document.getElementById('td-vpce-az2').textContent=azCount;
document.getElementById('td-vpce-hourly').textContent=vpceHourly.toFixed(2);
document.getElementById('td-vpce-data').textContent=vpceDataProcessing.toFixed(2);
document.getElementById('td-m2m-req').textContent=m2mTokenRequests.toLocaleString();
document.getElementById('td-m2m-cost').textContent=m2mCost.toFixed(2);
document.getElementById('td-total').textContent=totalMonthly.toFixed(2);
}
document.getElementById('input-requests').addEventListener('input',calculate);
document.getElementById('input-size').addEventListener('input',calculate);
document.getElementById('input-resp').addEventListener('input',calculate);
document.getElementById('input-az').addEventListener('input',calculate);
document.getElementById('input-dx').addEventListener('input',calculate);
document.getElementById('input-rate').addEventListener('input',calculate);
calculate();
})();
</script>
