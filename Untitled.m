colorp= {[1 1 0]; [1 0 1]; [0 1 1]; [1 0 0]; [0 1 0]; [0 0 1]; [0.5 0.5 0.5]; [0.7 0.7 0]; [0.7 0 0.7];...
    [0 0.7 0.7]; [0.7 0 0]; [0 0.7 0]; [0 0 0.7]; [0.3 0.3 0]; [0.3 0 0.3]; [0 0.3 0.3]; [0.3 0 0]; [0 0.3 0]; [0 0 0.3];...
    [0.5 0.5 0]; [0.5 0 0.5]; [0 0.5 0.5]; [0.5 0 0]; [0 0.5 0]; [0 0 0.5]};

test_r=find(tg(n).tier{1,1}.Label(1:(tx-1)),tg(n).tier{1,1}.Label(tx)); %comprueba si esa silaba ya estaba presente antes
if test_r==1 %si lo estaba
    patch([tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T2(tx) tg(n).tier{1,1}.T2(tx)],[ax(1).YLim(1) ax(1).YLim(2) ax(1).YLim(2) ax(1).YLim(1)],colorp{test_r(1)},'FaceAlpha',0.15,'EdgeColor','none'); %entonces el parche es del mismo color
else %sino, el parche es del color que sigue en la lista de colores
    patch([tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T2(tx) tg(n).tier{1,1}.T2(tx)],[ax(1).YLim(1) ax(1).YLim(2) ax(1).YLim(2) ax(1).YLim(1)],colorp{tx},'FaceAlpha',0.15,'EdgeColor','none'); 
end

 if  %esto es solo para lograr que alterne colores, si tx es par hace una cosa y si es impar otra
        patch([tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T2(tx) tg(n).tier{1,1}.T2(tx)],[ax(1).YLim(1) ax(1).YLim(2) ax(1).YLim(2) ax(1).YLim(1)],colorp{tx},'FaceAlpha',0.15,'EdgeColor','none'); 
           % else
        %patch([tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T2(tx) tg(n).tier{1,1}.T2(tx)],[ax(1).YLim(1) ax(1).YLim(2) ax(1).YLim(2) ax(1).YLim(1)],[1/num_silb*tx 0.5+0.5/num_silb*tx 1-1/num_silb*tx],'FaceAlpha',0.17,'EdgeColor','none'); 
         %   end 