 
--1.公共事件消息 
--2.公共数据类型 
--3.公共常量配置
EventType = {}

EventType.DefaultAnchor 	  =   cc.p(0.5,0.5)
 
--鱼鱼动画类型
EventType.UnKown_Animate_Type =   0    --未知动画类型
EventType.Normal_Animate_Type =   1    --普通游动类型
EventType.Eat_Animate_Type    =   2    --吃食动画类型
EventType.Turn_Animate_Type   =   3    --转身动画类型
EventType.Ext_Animate_Type    =   4    --扩展动画类型
EventType.Animate_Type_Count  =   4    --鱼鱼模型动画数目
 

--鱼缸喂食状态
EventType.UnKownFeedState     =   0   --未知喂食状态 
EventType.FeedingState		  =   1   --自己正在喂食状态
EventType.StopingState        =   2   --准备停止喂食状态
EventType.StopedState         =   3   --强制停止所有喂食状态
EventType.friendFeedingState  =   4   --为好友喂食状态 


--鱼缸触摸状态
EventType.IdleTouchState 	  =   0   --空闲状态触摸事件
EventType.FeedingTouchState   =   1   --喂食触摸事件
EventType.DisableTouchState   =   2   --禁止鱼缸触摸事件


--鱼鱼游动状态
EventType.NormalSwimState     =   0   --普通游动状态
EventType.ScareSwimState	  =   1   --主人惊吓游动状态
EventType.SleepState	  	  =   2   --睡眠游动状态
EventType.FeedState	  	 	  =   3   --喂食游动状态
EventType.MonsterScareState	  =   4   --怪物惊吓游动状态



--全局触摸事件类型
EventType.TouchBegin          =   0
EventType.TouchMoved  		  =   1
EventType.TouchEnded 		  =   2
EventType.TouchCancel         =   3
 

--GlobalMode 名称
EventType.FishAnimatesCache   =  "FishAnimatesCache"   --鱼鱼公共动画缓存管理器



--EventManager 事件名称
EventType.FeedFootEvent 	  =  10000				   --喂食事件通知
EventType.FeedFootLostEvent	  =  10001				   --食物消失事件通知
EventType.FeedFootEatEvent	  =  10002				   --食物消失事件通知


--EventType.AnimateEndEvent   =  "AnimEndEvent"        --动画播放结束事件通知
 

--变速动画类型
--EaseExponentialOut
--EaseSineOut
--EaseElasticOut --反向
--EaseBounceOut 弹动动画
--EaseBackOut --反弹动画
--EaseBezierAction
--EaseQuadraticActionIn
--EaseQuadraticActionOut
--EaseQuinticActionInOut
--EaseCircleActionIn --循环














return  EventType








