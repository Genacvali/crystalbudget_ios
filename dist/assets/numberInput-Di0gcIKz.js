const s=(l,a)=>{const n=l.replace(/[^\d.,]/g,"").replace(",","."),e=n.split("."),c=e.length>2?e[0]+"."+e.slice(1).join(""):n;a(c)};export{s as h};
