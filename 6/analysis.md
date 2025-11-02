# Отчёт по результатам анализа Kubernetes Audit Log

## Подозрительные события

1. Доступ к секретам:
   - Кто: minikube-user
   - Где: namespace kube-system 
   - Почему подозрительно: secrets is forbidden: User \"system:serviceaccount:secure-ops:monitoring\" cannot list resource \"secrets\" in API group \"\" in the namespace \"kube-system\""

2. Привилегированные поды:
   - Кто: minikube-user
   - Комментарий: создание привилегированного пода с priveleged:true

3. Использование kubectl exec в чужом поде:
   Отсутствует

4. Создание RoleBinding с правами cluster-admin:
   - Кто: minikube-user
   - К чему привело: Возможно выполнять любые операции в кластере

5. Удаление audit-policy.yaml:
   - Кто: system:node:minikube
   - Возможные последствия: Удаление этого файла может привести к отключению аудита или исключению из него определенных событий

## Вывод

В кластере были замечены подозрительные действия. Нужно проверить пользователя minikube-user и восстановить настройки безопасности.
