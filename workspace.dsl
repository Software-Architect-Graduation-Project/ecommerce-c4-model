workspace {

    model {
        customer = person "Cliente do Ecommerce"
        ecommerceSystem = softwareSystem "Plataforma de Ecommerce" {
          kafka = container "Kafka" "Event Broker"

          orderReceiver = container "Order Receiver" "Ponto de entrada para realização de pedidos. Recebe os pedidos e inicia a cadeia de eventos do fluxo." "Java e Spring Boot" {
            ecommerceOrderController = component "EcommerceOrderController"
            orderReceiverKafkaTemplate = component "KafkaTemplate"
            ecommerceOrderRepository = component "EcommerceOrderRepository"
          }
          orderReceiverDataBase = container "Order Receiver Data Base" "Armazena os dados do pedido recebido" "PostgreSQL"

          orderProcessor = container "Order Processor" "Escuta eventos durante o processamento dos pedidos armazenando as transições entre as etapas." "Java e Spring Boot" {
            newOrderListener = component "NewOrderListener"
            ecommerceOrderProcessor = component "EcommerceOrderProcessor"
            orderProcessorKafkaTemplate = component "KafkaTemplate"
            ecommerceOrderRecordRepository = component "EcommerceOrderRecordRepository"
          }
          orderProcessorDataBase = container "Order Processor Data Base" "Armazena informações sobre as transições que o pedido passa" "PostgreSQL"

          payments = container "Payments" "Processa os pagamentos dos pedidos." "Java e Spring Boot" {
            paymentProcessor = component "PaymentProcessor"
            paymentKafkaTemplate = component "KafkaTemplate"
            paymentRepository = component "PaymentRepository"
          }
          paymentsDataBase = container "Payments Data Base" "Armazena informações sobre o pagamento de pedidos" "PostgreSQL"

          stock = container "Stock" "Gerencia a separação dos itens do pedido no estoque." "Java e Spring Boot" {
            stockProcessor = component "StockProcessor"
            stockKafkaTemplate = component "KafkaTemplate"
            stockRepository = component "StockRepository"
          }
          stockDataBase = container "Stock Data Base" "Armazena informações sobre o gerenciamento do estoque" "PostgreSQL"

          logistic = container "Logistic" "Organiza a logística de entrega dos itens do pedido." "Java e Spring Boot" {
            logisticProcessor = component "LogisticProcessor"
            logisticKafkaTemplate = component "KafkaTemplate"
            logisticRepository = component "LogisticRepository"
          }
          logisticDataBase = container "Logistic Data Base" "Armazena informações sobre a logística" "PostgreSQL"
          
          productViewer = container "Product Viewer" "Expõe detalhes dos produtos para visualização." "Java e Spring Boot" {
            productController = component "ProductController"
            productRepository = component "ProductRepository"
          }
          productViewerDataBase = container "Product Viewer Data Base" "Armazena informações sobre os produtos" "PostgreSQL"
        }

        # relationships between people and software systems
        customer -> ecommerceSystem "Cliente da Plataforma de Ecommerce. Visualiza produtos e realiza pedidos."

        # relationships to/from containers
        customer -> orderReceiver "Realiza um pedido" "HTTPS"
        customer -> productViewer "Visualiza itens disponíveis" "HTTPS"
        
        orderReceiver -> orderReceiverDataBase "Armazena os dados do pedido"
        
        orderProcessor -> orderReceiver "Escuta o evento new_ecommerce_order"
        orderProcessor -> orderProcessorDataBase "Armazena a transição de estados do pedido"

        payments -> orderProcessor "Escuta o evento payment_received"
        payments -> paymentsDataBase "Armazena informações sobre os pagamentos"

        stock -> payments "Escuta o evento payment_processed"
        stock -> stockDataBase "Armazena nformações sobre a separação dos itens no estoque"

        logistic -> stock "Escuta o evento stock_separated"
        logistic -> logisticDataBase "Armazena informações sobre a operação de logística de entrega"

        productViewer -> productViewerDataBase "Armazena informações sobre os produtos"

         # relationships to/from components
        customer -> ecommerceOrderController "Recebe a requisição para criação do pedido" "JSON/HTTPS"
        ecommerceOrderController -> orderReceiverKafkaTemplate "Solicita emissão do evento"
        orderReceiverKafkaTemplate -> kafka "Emite o evento new_ecommerce_order"
        ecommerceOrderController -> ecommerceOrderRepository "Solicita persistência dos dados"
        ecommerceOrderRepository -> orderReceiverDataBase "Persiste os dados do pedido"

        newOrderListener -> kafka "Escuta o evento new_ecommerce_order"
        newOrderListener -> ecommerceOrderProcessor "Inicia o processamento do evento"
        ecommerceOrderProcessor -> ecommerceOrderRecordRepository "Solicita a atualização do status do pedido"
        ecommerceOrderProcessor -> orderProcessorKafkaTemplate "Solicita emissão do evento"
        orderProcessorKafkaTemplate -> kafka "Emite o evento payment_received"
        ecommerceOrderRecordRepository -> orderProcessorDataBase "Persiste um registro com o estado atualizado do pedido"

        paymentProcessor -> kafka "Escuta o evento payment_received"
        paymentProcessor -> paymentRepository "Solicita a atualização dos dados do pagamento"
        paymentRepository -> paymentsDataBase "Persiste os dados do pagamento"
        paymentProcessor -> paymentKafkaTemplate "Solicita emissão do evento"
        paymentKafkaTemplate -> kafka "Emite o evento payment_processed"

        stockProcessor -> kafka "Escuta o evento payment_processed"
        stockProcessor -> stockRepository "Solicita a atualização dos dados do estoque"
        stockRepository -> stockDataBase "Persiste os dados sobre a separação no estoque"
        stockProcessor -> stockKafkaTemplate "Solicita emissão do evento"
        stockKafkaTemplate -> kafka "Emite o evento stock_separated"

        logisticProcessor -> kafka "Escuta o evento stock_separated"
        logisticProcessor -> logisticRepository "Solicita a atualização dos dados da entrega"
        logisticRepository -> logisticDataBase "Persiste os dados sobre a entrega"
        logisticProcessor -> logisticKafkaTemplate "Solicita emissão do evento"
        logisticKafkaTemplate -> kafka "Emite o evento ready_to_delivery"

        customer -> productController "Recebe a requisição para visualização de um produto" "JSON/HTTPS"
        productController -> productRepository "Solicita as informações sobre o produto"
        productRepository -> productViewerDataBase "Recupera as informações do banco de dados"
    }

    views {
        theme default
        
        systemContext ecommerceSystem {
            include *
        }

        container ecommerceSystem "Containers" {
            include *
            exclude kafka
            animation {
                customer
                orderReceiver
                productViewer
                orderProcessor
                payments
                stock
                logistic
            }
        }

        component orderReceiver "Component_Order_Receiver" {
          include *
          autoLayout
        }

        component orderProcessor "Component_Order_Processor" {
          include *
        }

        component payments "Component_Payments" {
          include *
        }

        component stock "Component_Stock" {
          include *
        }

        component logistic "Component_Logistic" {
          include *
        }

        component productViewer "Component_Product_Viewer" {
          include *
          autoLayout
        }
    }
    
}